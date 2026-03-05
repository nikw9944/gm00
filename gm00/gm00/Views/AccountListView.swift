import SwiftUI

struct AccountListView: View {
    let accountTypeInfo: AccountTypeInfo
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel = AccountListViewModel()

    init(accountTypeInfo: AccountTypeInfo, navigationPath: Binding<NavigationPath>) {
        self.accountTypeInfo = accountTypeInfo
        self._navigationPath = navigationPath
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading \(accountTypeInfo.name)...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            viewModel.rpcClient = settingsViewModel.createRPCClient()
                            await viewModel.loadAccounts()
                        }
                    }
                }
                .padding()
            } else if viewModel.accounts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No \(accountTypeInfo.name) found")
                        .foregroundColor(.secondary)
                }
            } else {
                List(viewModel.accounts, id: \.pubkey) { account in
                    Button {
                        navigationPath.append(NavigationDestination.accountDetail(
                            pubkey: account.pubkey,
                            accountData: viewModel.rawDataCache[account.pubkey]
                        ))
                    } label: {
                        AccountRowView(account: account)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(accountTypeInfo.name)
        .refreshable {
            viewModel.rpcClient = settingsViewModel.createRPCClient()
            await viewModel.loadAccounts()
        }
        .task {
            viewModel.accountTypeInfo = accountTypeInfo
            viewModel.rpcClient = settingsViewModel.createRPCClient()
            await viewModel.loadAccounts()
        }
    }
}
