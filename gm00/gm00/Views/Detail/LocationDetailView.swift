import SwiftUI

struct LocationDetailView: View {
    let pubkey: String
    let location: LocationAccount
    @Binding var navigationPath: NavigationPath

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

            DetailSection(title: "References") {
                DetailRow(label: "Reference Count", value: "\(location.referenceCount)")
            }

            DetailSection(title: "Account Info") {
                PubkeyLinkView(label: "Owner", pubkey: location.owner, navigationPath: $navigationPath)
            }
        }
    }
}
