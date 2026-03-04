import SwiftUI

struct MulticastGroupDetailView: View {
    let pubkey: String
    let multicastGroup: MulticastGroupAccount
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: multicastGroup.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(multicastGroup.status.displayName)
                }
            }

            DetailSection(title: "Network") {
                IPAddressView(label: "Multicast IP", ip: multicastGroup.multicastIp)
                DetailRow(label: "Max Bandwidth", value: multicastGroup.maxBandwidth.formattedBandwidth)
            }

            DetailSection(title: "Membership") {
                DetailRow(label: "Publishers", value: "\(multicastGroup.publisherCount)")
                DetailRow(label: "Subscribers", value: "\(multicastGroup.subscriberCount)")
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Tenant", pubkey: multicastGroup.tenantPk, navigationPath: $navigationPath)
            }
        }
    }
}
