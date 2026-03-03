import SwiftUI

struct TenantDetailView: View {
    let pubkey: String
    let tenant: TenantAccount
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: tenant.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                DetailRow(label: "VRF ID", value: "\(tenant.vrfId)")
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Payment Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(tenant.paymentStatus.displayName)
                }
            }

            DetailSection(title: "Configuration") {
                DetailRow(label: "Metro Routing", value: tenant.metroRouting ? "Enabled" : "Disabled")
                DetailRow(label: "Route Liveness", value: tenant.routeLiveness ? "Enabled" : "Disabled")
                DetailRow(label: "Reference Count", value: "\(tenant.referenceCount)")
            }

            DetailSection(title: "Billing") {
                DetailRow(label: "Rate", value: "\(tenant.billing.rate)")
                DetailRow(label: "Last Deduction Epoch", value: "\(tenant.billing.lastDeductionDzEpoch)")
            }

            if !tenant.administrators.isEmpty {
                DetailSection(title: "Administrators (\(tenant.administrators.count))") {
                    ForEach(tenant.administrators, id: \.self) { pk in
                        PubkeyLinkView(label: "", pubkey: pk, navigationPath: $navigationPath)
                    }
                }
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Token Account", pubkey: tenant.tokenAccount, navigationPath: $navigationPath)
            }
        }
    }
}
