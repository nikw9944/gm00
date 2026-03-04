import Foundation

@MainActor
class AccountDetailViewModel: ObservableObject {
    @Published var resolvedAccount: ResolvedAccount?
    @Published var isLoading = false
    @Published var error: String?
    @Published var userDisplayCode: String?

    var rpcClient: SolanaRPCClient?

    func loadAccount(pubkey: String, preloadedData: Data? = nil) async {
        guard let rpcClient else { return }
        isLoading = true
        error = nil

        do {
            let resolver = AccountResolver(rpcClient: rpcClient)
            if let data = preloadedData {
                resolvedAccount = try resolver.resolveFromData(pubkey: pubkey, data: data)
            } else {
                resolvedAccount = try await resolver.resolve(pubkey: pubkey)
            }

            // Resolve User display code
            if case .user(let pk, var user) = resolvedAccount {
                await resolveUserCode(&user, rpcClient: rpcClient)
                user.pubkey = pk
                resolvedAccount = .user(pk, user)
            }

            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    private func resolveUserCode(_ user: inout DZUser, rpcClient: SolanaRPCClient) async {
        do {
            let deviceData = try await rpcClient.getAccountInfo(pubkey: user.devicePk)
            let decoder = BorshDecoder(data: deviceData)
            let device = try DeviceAccount.decode(from: decoder)

            let exchangeData = try await rpcClient.getAccountInfo(pubkey: device.exchangePk)
            let exDecoder = BorshDecoder(data: exchangeData)
            let exchange = try ExchangeAccount.decode(from: exDecoder)

            user.displayCode = "\(exchange.code):\(device.code):\(user.tunnelId)"
        } catch {
            user.displayCode = "???:???:\(user.tunnelId)"
        }
    }
}
