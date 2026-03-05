import Foundation

@MainActor
class AccountListViewModel: ObservableObject {
    @Published var accounts: [ResolvedAccount] = []
    @Published var isLoading = false
    @Published var error: String?

    var rpcClient: SolanaRPCClient?
    var accountTypeInfo: AccountTypeInfo?

    // Raw data cache for passing to detail views
    private(set) var rawDataCache: [String: Data] = [:]

    // Caches for User composite code resolution
    private var deviceCodeCache: [String: (deviceCode: String, exchangePk: String)] = [:]
    private var exchangeCodeCache: [String: String] = [:]

    func loadAccounts() async {
        guard let rpcClient, let accountTypeInfo else { return }
        isLoading = true
        error = nil

        do {
            let rawAccounts = try await rpcClient.getAccountsByType(accountTypeInfo.id)
            var resolved: [ResolvedAccount] = []
            let resolver = AccountResolver(rpcClient: rpcClient)
            rawDataCache.removeAll()

            for (pubkey, data) in rawAccounts {
                do {
                    let account = try resolver.resolveFromData(pubkey: pubkey, data: data)
                    resolved.append(account)
                    rawDataCache[pubkey] = data
                } catch {
                    print("Failed to decode account \(pubkey): \(error)")
                    continue
                }
            }

            // Resolve User composite codes if this is a User list
            if accountTypeInfo.id == AccountTypeDiscriminator.user {
                resolved = await resolveUserDisplayCodes(resolved)
            }

            accounts = sortAccounts(resolved)
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    private func resolveUserDisplayCodes(_ accounts: [ResolvedAccount]) async -> [ResolvedAccount] {
        guard let rpcClient else { return accounts }
        var users: [(index: Int, user: DZUser, pubkey: String)] = []
        var result = accounts

        for (i, account) in accounts.enumerated() {
            if case .user(let pk, let user) = account {
                users.append((index: i, user: user, pubkey: pk))
            }
        }

        guard !users.isEmpty else { return result }

        // Collect unique device pubkeys
        let devicePks = Array(Set(users.map { $0.user.devicePk }))

        // Batch fetch devices
        do {
            let deviceResults = try await rpcClient.getMultipleAccounts(pubkeys: devicePks)
            for (pubkey, data) in deviceResults {
                guard let data = data else { continue }
                let decoder = BorshDecoder(data: data)
                if let device = try? DeviceAccount.decode(from: decoder) {
                    deviceCodeCache[pubkey] = (deviceCode: device.code, exchangePk: device.exchangePk)
                }
            }
        } catch {
            // Continue with partial data
        }

        // Collect unique exchange pubkeys
        let exchangePks = Array(Set(deviceCodeCache.values.map { $0.exchangePk }))

        // Batch fetch exchanges
        do {
            let exchangeResults = try await rpcClient.getMultipleAccounts(pubkeys: exchangePks)
            for (pubkey, data) in exchangeResults {
                guard let data = data else { continue }
                let decoder = BorshDecoder(data: data)
                if let exchange = try? ExchangeAccount.decode(from: decoder) {
                    exchangeCodeCache[pubkey] = exchange.code
                }
            }
        } catch {
            // Continue with partial data
        }

        // Build composite codes
        for (index, user, pubkey) in users {
            var updatedUser = user
            updatedUser.pubkey = pubkey

            if let deviceInfo = deviceCodeCache[user.devicePk] {
                let exchangeCode = exchangeCodeCache[deviceInfo.exchangePk] ?? "???"
                updatedUser.displayCode = "\(exchangeCode):\(deviceInfo.deviceCode):\(user.tunnelId)"
            } else {
                updatedUser.displayCode = "???:???:\(user.tunnelId)"
            }

            result[index] = .user(pubkey, updatedUser)
        }

        return result
    }

    private func sortAccounts(_ accounts: [ResolvedAccount]) -> [ResolvedAccount] {
        accounts.sorted { a, b in
            sortKey(for: a).localizedCaseInsensitiveCompare(sortKey(for: b)) == .orderedAscending
        }
    }

    private func sortKey(for account: ResolvedAccount) -> String {
        switch account {
        case .location(_, let l): return l.code
        case .exchange(_, let e): return e.code
        case .device(_, let d): return d.code
        case .link(_, let l): return l.code
        case .user(_, let u): return u.sortKey
        case .multicastGroup(_, let m): return m.code
        case .contributor(_, let c): return c.code
        case .tenant(_, let t): return t.code
        case .accessPass(_, let a): return a.clientIp
        case .reservation(_, let r): return r.clientIp
        }
    }
}
