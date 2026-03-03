import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [ResolvedAccount] = []
    @Published var isSearching = false
    @Published var error: String?
    @Published var hasSearched = false

    var rpcClient: SolanaRPCClient?
    private var cachedAccounts: [ResolvedAccount] = []
    private var hasFetchedAll = false

    func search() async {
        guard let rpcClient else { return }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            results = []
            hasSearched = false
            return
        }

        isSearching = true
        error = nil
        hasSearched = true

        do {
            if !hasFetchedAll {
                try await fetchAllAccounts(rpcClient: rpcClient)
            }

            let lowercasedQuery = query.lowercased()
            results = cachedAccounts.filter { account in
                searchableText(for: account).lowercased().contains(lowercasedQuery)
            }

            isSearching = false
        } catch {
            self.error = error.localizedDescription
            isSearching = false
        }
    }

    func clearCache() {
        cachedAccounts = []
        hasFetchedAll = false
    }

    private func fetchAllAccounts(rpcClient: SolanaRPCClient) async throws {
        let resolver = AccountResolver(rpcClient: rpcClient)
        var all: [ResolvedAccount] = []

        for typeInfo in AccountTypeInfo.browsableTypes {
            let rawAccounts = try await rpcClient.getAccountsByType(typeInfo.id)
            for (pubkey, data) in rawAccounts {
                if let account = try? resolver.resolveFromData(pubkey: pubkey, data: data) {
                    all.append(account)
                }
            }
        }

        cachedAccounts = all
        hasFetchedAll = true
    }

    private func searchableText(for account: ResolvedAccount) -> String {
        switch account {
        case .location(let pk, let a): return "\(a.searchableText) \(pk)"
        case .exchange(let pk, let a): return "\(a.searchableText) \(pk)"
        case .device(let pk, let a): return "\(a.searchableText) \(pk)"
        case .link(let pk, let a): return "\(a.searchableText) \(pk)"
        case .user(let pk, let a): return "\(a.searchableText) \(pk)"
        case .multicastGroup(let pk, let a): return "\(a.searchableText) \(pk)"
        case .contributor(let pk, let a): return "\(a.searchableText) \(pk)"
        case .tenant(let pk, let a): return "\(a.searchableText) \(pk)"
        case .accessPass(let pk, let a): return "\(a.searchableText) \(pk)"
        case .reservation(let pk, let a): return "\(a.searchableText) \(pk)"
        }
    }
}
