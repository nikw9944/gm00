import SwiftUI

struct ExchangeDetailView: View {
    let pubkey: String
    let exchange: ExchangeAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var locations: [(pubkey: String, location: LocationAccount)] = []
    @State private var isLoadingLocations = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: exchange.code)
                DetailRow(label: "Name", value: exchange.name)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(exchange.status.displayName)
                }
            }

            DetailSection(title: "Network") {
                DetailRow(label: "BGP Community", value: "\(exchange.bgpCommunity)")
            }

            DetailSection(title: "Location") {
                DetailRow(label: "Latitude", value: String(format: "%.6f", exchange.lat))
                DetailRow(label: "Longitude", value: String(format: "%.6f", exchange.lng))
            }

            DetailSection(title: "Devices") {
                PubkeyLinkView(label: "Device 1", pubkey: exchange.device1Pk, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Device 2", pubkey: exchange.device2Pk, navigationPath: $navigationPath)
            }

            DetailSection(title: "Locations") {
                if isLoadingLocations {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if locations.isEmpty {
                    Text("No locations found")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(locations, id: \.pubkey) { item in
                        CodeLinkView(
                            label: item.location.code,
                            pubkey: item.pubkey,
                            code: item.location.name,
                            navigationPath: $navigationPath
                        )
                    }
                }
            }

            DetailSection(title: "References") {
                DetailRow(label: "Reference Count", value: "\(exchange.referenceCount)")
            }
        }
        .task {
            await loadLocations()
        }
    }

    private func loadLocations() async {
        isLoadingLocations = true
        defer { isLoadingLocations = false }

        let client = settingsViewModel.createRPCClient()
        do {
            let deviceResults = try await client.getDevicesForExchange(pubkey: pubkey)
            var uniqueLocationPks = Set<String>()
            for (_, data) in deviceResults {
                let decoder = BorshDecoder(data: data)
                if let device = try? DeviceAccount.decode(from: decoder) {
                    if !device.locationPk.allSatisfy({ $0 == "1" }) {
                        uniqueLocationPks.insert(device.locationPk)
                    }
                }
            }

            guard !uniqueLocationPks.isEmpty else { return }

            let locationResults = try await client.getMultipleAccounts(pubkeys: Array(uniqueLocationPks))
            var decoded: [(pubkey: String, location: LocationAccount)] = []
            for (pk, data) in locationResults {
                guard let data else { continue }
                let decoder = BorshDecoder(data: data)
                if let loc = try? LocationAccount.decode(from: decoder) {
                    decoded.append((pubkey: pk, location: loc))
                }
            }
            locations = decoded.sorted { $0.location.code < $1.location.code }
        } catch {
            // Silently fail — section shows "No locations found"
        }
    }
}
