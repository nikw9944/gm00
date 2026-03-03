import SwiftUI

struct AccessPassDetailView: View {
    let pubkey: String
    let accessPass: AccessPassAccount
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                IPAddressView(label: "Client IP", ip: accessPass.clientIp)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                DetailRow(label: "Type", value: accessPass.accessPassType.displayName)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(accessPass.status.displayName)
                }
                DetailRow(label: "Connections", value: "\(accessPass.connectionCount)")
                DetailRow(label: "Last Access Epoch", value: "\(accessPass.lastAccessEpoch)")
            }

            DetailSection(title: "Flags") {
                DetailRow(label: "Dynamic", value: accessPass.isDynamic ? "Yes" : "No")
                DetailRow(label: "Allow Multiple IP", value: accessPass.allowMultipleIp ? "Yes" : "No")
            }

            if !accessPass.mgroupPubAllowlist.isEmpty {
                DetailSection(title: "Multicast Pub Allowlist (\(accessPass.mgroupPubAllowlist.count))") {
                    ForEach(accessPass.mgroupPubAllowlist, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            if !accessPass.mgroupSubAllowlist.isEmpty {
                DetailSection(title: "Multicast Sub Allowlist (\(accessPass.mgroupSubAllowlist.count))") {
                    ForEach(accessPass.mgroupSubAllowlist, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            if !accessPass.tenantAllowlist.isEmpty {
                DetailSection(title: "Tenant Allowlist (\(accessPass.tenantAllowlist.count))") {
                    ForEach(accessPass.tenantAllowlist, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "User Payer", pubkey: accessPass.userPayer, navigationPath: $navigationPath)
            }
        }
    }
}
