import SwiftUI

struct CodeLinkView: View {
    let label: String
    let pubkey: String
    let code: String?
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if pubkey.allSatisfy({ $0 == "1" }) {
            HStack {
                Text(label)
                    .foregroundColor(.secondary)
                Spacer()
                Text("None")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        } else {
            Button {
                navigationPath.append(NavigationDestination.accountDetail(
                    pubkey: pubkey,
                    accountData: nil
                ))
            } label: {
                HStack {
                    Text(label)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(code ?? pubkey.truncatedPubkey)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
