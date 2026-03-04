import SwiftUI

struct IPAddressView: View {
    let label: String
    let ip: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(ip)
                .font(.system(.body, design: .monospaced))
        }
    }
}
