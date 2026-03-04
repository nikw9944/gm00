import SwiftUI

struct ExchangeDetailView: View {
    let pubkey: String
    let exchange: ExchangeAccount
    @Binding var navigationPath: NavigationPath

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

            DetailSection(title: "References") {
                DetailRow(label: "Reference Count", value: "\(exchange.referenceCount)")
            }
        }
    }
}
