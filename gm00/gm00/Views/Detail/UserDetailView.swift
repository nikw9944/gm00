import SwiftUI

struct UserDetailView: View {
    let pubkey: String
    let user: DZUser
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let displayCode = user.displayCode {
                DetailSection(title: "Identity") {
                    DetailRow(label: "Code", value: displayCode)
                    DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                    DetailRow(label: "Type", value: user.userType.displayName)
                    DetailRow(label: "CYOA", value: user.cyoaType.displayName)
                }
            } else {
                DetailSection(title: "Identity") {
                    DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                    DetailRow(label: "Type", value: user.userType.displayName)
                    DetailRow(label: "CYOA", value: user.cyoaType.displayName)
                }
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(user.status.displayName)
                }
            }

            DetailSection(title: "Network") {
                IPAddressView(label: "Client IP", ip: user.clientIp)
                IPAddressView(label: "DZ IP", ip: user.dzIp)
                IPAddressView(label: "Tunnel Endpoint", ip: user.tunnelEndpoint)
                DetailRow(label: "Tunnel ID", value: "\(user.tunnelId)")
                DetailRow(label: "Tunnel Net", value: user.tunnelNet.description)
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Tenant", pubkey: user.tenantPk, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Device", pubkey: user.devicePk, navigationPath: $navigationPath)
            }

            if !user.publishers.isEmpty {
                DetailSection(title: "Publishers (\(user.publishers.count))") {
                    ForEach(user.publishers, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            if !user.subscribers.isEmpty {
                DetailSection(title: "Subscribers (\(user.subscribers.count))") {
                    ForEach(user.subscribers, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            DetailSection(title: "Validator") {
                PubkeyLinkView(label: "Validator Pubkey", pubkey: user.validatorPubkey, navigationPath: $navigationPath)
            }
        }
    }
}
