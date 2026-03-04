import SwiftUI

struct ContributorDetailView: View {
    let pubkey: String
    let contributor: ContributorAccount
    @Binding var navigationPath: NavigationPath

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
        }
    }
}
