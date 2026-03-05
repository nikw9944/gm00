import Foundation
import os

@MainActor
class HomeViewModel: ObservableObject {
    @Published var accountTypes: [AccountTypeInfo] = AccountTypeInfo.browsableTypes
    @Published var accountCounts: [UInt8: Int] = [:]

    private let logger = Logger(subsystem: "com.gm00", category: "HomeViewModel")

    func loadCounts(client: SolanaRPCClient) async {
        accountCounts = [:]
        do {
            let counts = try await client.getAllAccountCounts()
            guard !Task.isCancelled else { return }
            accountCounts = counts
        } catch {
            logger.error("Failed to load account counts: \(error.localizedDescription)")
        }
    }
}
