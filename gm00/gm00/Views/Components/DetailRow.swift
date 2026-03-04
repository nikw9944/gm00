import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    var monospaced: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(monospaced ? .system(.body, design: .monospaced) : .body)
                .multilineTextAlignment(.trailing)
        }
    }
}
