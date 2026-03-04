import SwiftUI

struct SearchView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel = SearchViewModel()

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hasSearched && viewModel.results.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No results found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.results.isEmpty {
                List(viewModel.results, id: \.pubkey) { account in
                    Button {
                        navigationPath.append(NavigationDestination.accountDetail(
                            pubkey: account.pubkey,
                            accountData: nil
                        ))
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.typeName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            AccountRowView(account: account)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Search across all account types")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchText, prompt: "Search accounts...")
        .onSubmit(of: .search) {
            Task {
                viewModel.rpcClient = settingsViewModel.createRPCClient()
                await viewModel.search()
            }
        }
        .task {
            viewModel.rpcClient = settingsViewModel.createRPCClient()
        }
    }
}
