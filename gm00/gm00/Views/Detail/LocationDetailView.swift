import SwiftUI

struct LocationDetailView: View {
    let pubkey: String
    let location: LocationAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var devices: [(pubkey: String, device: DeviceAccount)] = []
    @State private var exchanges: [(pubkey: String, exchange: ExchangeAccount)] = []
    @State private var isLoadingRelated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: location.code)
                DetailRow(label: "Name", value: location.name)
                DetailRow(label: "Country", value: location.country)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(location.status.displayName)
                }
            }

            DetailSection(title: "Location") {
                DetailRow(label: "Latitude", value: String(format: "%.6f", location.lat))
                DetailRow(label: "Longitude", value: String(format: "%.6f", location.lng))
                DetailRow(label: "Location ID", value: "\(location.locId)")
            }

            DetailSection(title: "Exchanges") {
                if isLoadingRelated {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if exchanges.isEmpty {
                    Text("No exchanges found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(exchanges, id: \.pubkey) { item in
                        CodeLinkView(
                            label: item.exchange.code,
                            pubkey: item.pubkey,
                            code: item.exchange.name,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }

            DetailSection(title: "Devices") {
                if isLoadingRelated {
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
                            code: nil,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }

            DetailSection(title: "References") {
                DetailRow(label: "Reference Count", value: "\(location.referenceCount)")
            }

            DetailSection(title: "Account Info") {
                PubkeyLinkView(label: "Owner", pubkey: location.owner, navigationPath: $navigationPath)
            }
        }
        .task {
            await loadRelated()
        }
    }

    private func loadRelated() async {
        isLoadingRelated = true
        defer { isLoadingRelated = false }

        let client = settingsViewModel.createRPCClient()
        do {
            let deviceResults = try await client.getDevicesForLocation(pubkey: pubkey)
            var decodedDevices: [(pubkey: String, device: DeviceAccount)] = []
            var uniqueExchangePks = Set<String>()

            for (pk, data) in deviceResults {
                let decoder = BorshDecoder(data: data)
                if let device = try? DeviceAccount.decode(from: decoder) {
                    decodedDevices.append((pubkey: pk, device: device))
                    if !device.exchangePk.allSatisfy({ $0 == "1" }) {
                        uniqueExchangePks.insert(device.exchangePk)
                    }
                }
            }
            devices = decodedDevices.sorted { $0.device.code < $1.device.code }

            guard !uniqueExchangePks.isEmpty else { return }

            let exchangeResults = try await client.getMultipleAccounts(pubkeys: Array(uniqueExchangePks))
            var decodedExchanges: [(pubkey: String, exchange: ExchangeAccount)] = []
            for (pk, data) in exchangeResults {
                guard let data else { continue }
                let decoder = BorshDecoder(data: data)
                if let ex = try? ExchangeAccount.decode(from: decoder) {
                    decodedExchanges.append((pubkey: pk, exchange: ex))
                }
            }
            exchanges = decodedExchanges.sorted { $0.exchange.code < $1.exchange.code }
        } catch {
            // Silently fail — sections show "No ... found"
        }
    }
}
