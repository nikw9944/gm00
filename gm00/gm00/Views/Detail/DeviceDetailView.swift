import SwiftUI

struct DeviceDetailView: View {
    let pubkey: String
    let device: DeviceAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var locationCode: String?
    @State private var exchangeCode: String?
    @State private var contributorCode: String?
    @State private var users: [(pubkey: String, user: DZUser)] = []
    @State private var isLoadingUsers = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: device.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                DetailRow(label: "Type", value: device.deviceType.displayName)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.status.displayName)
                }
                HStack {
                    Text("Health")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.deviceHealth.displayName)
                }
                HStack {
                    Text("Desired Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.desiredStatus.displayName)
                }
            }

            DetailSection(title: "Network") {
                IPAddressView(label: "Public IP", ip: device.publicIp)
                DetailRow(label: "Mgmt VRF", value: device.mgmtVrf)
                if !device.dzPrefixes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DZ Prefixes")
                            .foregroundColor(.secondary)
                        ForEach(device.dzPrefixes, id: \.description) { prefix in
                            Text(prefix.description)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }

            DetailSection(title: "Capacity") {
                DetailRow(label: "Users", value: "\(device.usersCount) / \(device.maxUsers)")
                DetailRow(label: "Unicast Users", value: "\(device.unicastUsersCount) / \(device.maxUnicastUsers)")
                DetailRow(label: "Multicast Users", value: "\(device.multicastUsersCount) / \(device.maxMulticastUsers)")
                DetailRow(label: "Reserved Seats", value: "\(device.reservedSeats)")
                DetailRow(label: "Reference Count", value: "\(device.referenceCount)")
            }

            DetailSection(title: "Related Accounts") {
                CodeLinkView(label: "Location", pubkey: device.locationPk, code: locationCode, navigationPath: $navigationPath)
                CodeLinkView(label: "Exchange", pubkey: device.exchangePk, code: exchangeCode, navigationPath: $navigationPath)
                CodeLinkView(label: "Contributor", pubkey: device.contributorPk, code: contributorCode, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Metrics Publisher", pubkey: device.metricsPublisherPk, navigationPath: $navigationPath)
            }

            if !device.interfaces.isEmpty {
                DetailSection(title: "Interfaces (\(device.interfaces.count))") {
                    ForEach(Array(device.interfaces.enumerated()), id: \.offset) { _, iface in
                        InterfaceRow(iface: iface)
                        Divider()
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
        }
        .task {
            async let codesTask: () = loadRelatedCodes()
            async let usersTask: () = loadUsers()
            _ = await (codesTask, usersTask)
        }
    }

    private func loadRelatedCodes() async {
        let client = settingsViewModel.createRPCClient()
        let pubkeys = [device.locationPk, device.exchangePk, device.contributorPk]
        let validPubkeys = pubkeys.filter { !$0.allSatisfy { $0 == "1" } }

        guard !validPubkeys.isEmpty else { return }

        do {
            let results = try await client.getMultipleAccounts(pubkeys: validPubkeys)
            let lookup = Dictionary(uniqueKeysWithValues: results.map { ($0.pubkey, $0.data) })

            if let data = lookup[device.locationPk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let loc = try? LocationAccount.decode(from: decoder) {
                    locationCode = loc.code
                }
            }
            if let data = lookup[device.exchangePk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let ex = try? ExchangeAccount.decode(from: decoder) {
                    exchangeCode = ex.code
                }
            }
            if let data = lookup[device.contributorPk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let contrib = try? ContributorAccount.decode(from: decoder) {
                    contributorCode = contrib.code
                }
            }
        } catch {
            // Codes remain nil — falls back to truncated pubkey display
        }
    }

    private func loadUsers() async {
        isLoadingUsers = true
        defer { isLoadingUsers = false }

        let client = settingsViewModel.createRPCClient()
        do {
            let results = try await client.getUsersForDevice(pubkey: pubkey)
            var decoded: [(pubkey: String, user: DZUser)] = []
            for (pk, data) in results {
                let decoder = BorshDecoder(data: data)
                if var user = try? DZUser.decode(from: decoder) {
                    user.pubkey = pk
                    decoded.append((pubkey: pk, user: user))
                }
            }
            users = decoded.sorted { $0.user.sortKey < $1.user.sortKey }
        } catch {
            // Silently fail — section shows "No users found"
        }
    }
}

struct InterfaceRow: View {
    let iface: Interface
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 4) {
                switch iface {
                case .v1(let v1):
                    DetailRow(label: "Version", value: "V1")
                    HStack { Text("Status").foregroundColor(.secondary); Spacer(); StatusBadgeView(v1.status.displayName) }
                    DetailRow(label: "Type", value: v1.interfaceType.displayName)
                    DetailRow(label: "Loopback", value: v1.loopbackType.displayName)
                    DetailRow(label: "VLAN", value: "\(v1.vlanId)")
                    DetailRow(label: "IP Net", value: v1.ipNet.description)
                    DetailRow(label: "Segment Idx", value: "\(v1.nodeSegmentIdx)")
                    DetailRow(label: "Tunnel Endpoint", value: v1.userTunnelEndpoint ? "Yes" : "No")
                case .v2(let v2):
                    DetailRow(label: "Version", value: "V2")
                    HStack { Text("Status").foregroundColor(.secondary); Spacer(); StatusBadgeView(v2.status.displayName) }
                    DetailRow(label: "Type", value: v2.interfaceType.displayName)
                    DetailRow(label: "CYOA", value: v2.interfaceCyoa.displayName)
                    DetailRow(label: "DIA", value: v2.interfaceDia.displayName)
                    DetailRow(label: "Loopback", value: v2.loopbackType.displayName)
                    DetailRow(label: "Bandwidth", value: v2.bandwidth.formattedBandwidth)
                    DetailRow(label: "CIR", value: v2.cir.formattedBandwidth)
                    DetailRow(label: "MTU", value: "\(v2.mtu)")
                    DetailRow(label: "Routing", value: v2.routingMode.displayName)
                    DetailRow(label: "VLAN", value: "\(v2.vlanId)")
                    DetailRow(label: "IP Net", value: v2.ipNet.description)
                    DetailRow(label: "Segment Idx", value: "\(v2.nodeSegmentIdx)")
                    DetailRow(label: "Tunnel Endpoint", value: v2.userTunnelEndpoint ? "Yes" : "No")
                }
            }
        } label: {
            HStack {
                Text(iface.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                StatusBadgeView(iface.status.displayName)
            }
        }
    }
}
