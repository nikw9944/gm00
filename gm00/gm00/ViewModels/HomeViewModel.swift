import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var accountTypes: [AccountTypeInfo] = AccountTypeInfo.browsableTypes
    @Published var accountCounts: [UInt8: Int] = [:]
    @Published var isLoadingCounts: Bool = false

    private var rpcClient: SolanaRPCClient?

    func updateClient(_ client: SolanaRPCClient) {
        self.rpcClient = client
    }

    func loadCounts() async {
        guard let client = rpcClient else { return }
        isLoadingCounts = true
        await withTaskGroup(of: (UInt8, Int?).self) { group in
            for typeInfo in accountTypes {
                let discriminator = typeInfo.id
                group.addTask {
                    do {
                        let count = try await client.getAccountCountByType(discriminator)
                        return (discriminator, count)
                    } catch {
                        return (discriminator, nil)
                    }
                }
            }
            for await (discriminator, count) in group {
                if let count {
                    accountCounts[discriminator] = count
                }
            }
        }
        isLoadingCounts = false
    }
}
