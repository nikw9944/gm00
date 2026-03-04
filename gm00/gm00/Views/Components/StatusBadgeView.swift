import SwiftUI

struct StatusBadgeView: View {
    let text: String
    let color: Color

    init(_ text: String) {
        self.text = text
        switch text.lowercased() {
        case "activated", "connected", "paid", "ready for service", "ready for users", "ready for links":
            self.color = .green
        case "pending", "requested", "unknown":
            self.color = .orange
        case "suspended", "impaired", "banned", "delinquent", "out of credits":
            self.color = .red
        case "deleting", "drained", "hard drained", "soft drained":
            self.color = .yellow
        case "rejected", "expired", "disconnected":
            self.color = .gray
        default:
            self.color = .secondary
        }
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}
