import SwiftUI

struct ContributorDetailView: View {
    let pubkey: String
    let contributor: ContributorAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var devices: [(pubkey: String, device: DeviceAccount)] = []
    @State private var users: [(pubkey: String, user: DZUser)] = []
    @State private var links: [(pubkey: String, link: LinkAccount)] = []
    @State private var isLoadingDevices = false
    @State private var isLoadingUsers = false
    @State private var isLoadingLinks = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: contributor.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(contributor.status.displayName)
                }
            }

            DetailSection(title: "References") {
                DetailRow(label: "Reference Count", value: "\(contributor.referenceCount)")
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Ops Manager", pubkey: contributor.opsManagerPk, navigationPath: $navigationPath)
            }

            DetailSection(title: "Devices (\(devices.count))") {
                if isLoadingDevices {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if devices.isEmpty {
                    Text("No devices found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(devices, id: \.pubkey) { item in
                        CodeLinkView(
                            label: item.device.code,
                            pubkey: item.pubkey,
                            code: item.device.code,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }

            DetailSection(title: "Users (\(users.count))") {
                if isLoadingUsers {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if users.isEmpty {
                    Text("No users found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(users, id: \.pubkey) { item in
                        CodeLinkView(
                            label: "Tunnel \(item.user.tunnelId)",
                            pubkey: item.pubkey,
                            code: item.user.dzIp,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }

            DetailSection(title: "Links (\(links.count))") {
                if isLoadingLinks {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if links.isEmpty {
                    Text("No links found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(links, id: \.pubkey) { item in
                        CodeLinkView(
                            label: item.link.code,
                            pubkey: item.pubkey,
                            code: item.link.code,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }
        }
        .task {
            await loadDevices()
            let devicePubkeys = devices.map { $0.pubkey }
            async let usersTask: () = loadUsers(forDevicePubkeys: devicePubkeys)
            async let linksTask: () = loadLinks()
            _ = await (usersTask, linksTask)
        }
    }

    private func loadDevices() async {
        isLoadingDevices = true
        defer { isLoadingDevices = false }

        let client = settingsViewModel.createRPCClient()
        do {
            let results = try await client.getAccountsByType(AccountTypeDiscriminator.device)
            var decoded: [(pubkey: String, device: DeviceAccount)] = []
            for (pk, data) in results {
                let decoder = BorshDecoder(data: data)
                if var device = try? DeviceAccount.decode(from: decoder) {
                    device.pubkey = pk
                    if device.contributorPk == pubkey {
                        decoded.append((pubkey: pk, device: device))
                    }
                }
            }
            devices = decoded.sorted { $0.device.code < $1.device.code }
        } catch {
            // Silently fail — section shows "No devices found"
        }
    }

    private func loadUsers(forDevicePubkeys devicePubkeys: [String]) async {
        isLoadingUsers = true
        defer { isLoadingUsers = false }

        guard !devicePubkeys.isEmpty else { return }

        let client = settingsViewModel.createRPCClient()
        var allUsers: [(pubkey: String, user: DZUser)] = []

        await withTaskGroup(of: [(pubkey: String, user: DZUser)].self) { group in
            for devicePk in devicePubkeys {
                group.addTask {
                    do {
                        let results = try await client.getUsersForDevice(pubkey: devicePk)
                        var decoded: [(pubkey: String, user: DZUser)] = []
                        for (pk, data) in results {
                            let decoder = BorshDecoder(data: data)
                            if var user = try? DZUser.decode(from: decoder) {
                                user.pubkey = pk
                                decoded.append((pubkey: pk, user: user))
                            }
                        }
                        return decoded
                    } catch {
                        return []
                    }
                }
            }
            for await result in group {
                allUsers.append(contentsOf: result)
            }
        }

        users = allUsers.sorted { $0.user.tunnelId < $1.user.tunnelId }
    }

    private func loadLinks() async {
        isLoadingLinks = true
        defer { isLoadingLinks = false }

        let client = settingsViewModel.createRPCClient()
        do {
            let results = try await client.getAccountsByType(AccountTypeDiscriminator.link)
            var decoded: [(pubkey: String, link: LinkAccount)] = []
            for (pk, data) in results {
                let decoder = BorshDecoder(data: data)
                if var link = try? LinkAccount.decode(from: decoder) {
                    link.pubkey = pk
                    if link.contributorPk == pubkey {
                        decoded.append((pubkey: pk, link: link))
                    }
                }
            }
            links = decoded.sorted { $0.link.code < $1.link.code }
        } catch {
            // Silently fail — section shows "No links found"
        }
    }
}
