import SwiftUI

enum NavigationDestination: Hashable {
    case accountList(AccountTypeInfo)
    case accountDetail(pubkey: String, accountData: Data?)
    case searchResults
}

struct ContentView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var navigationPath = NavigationPath()
    @State private var showSettings = false
    @State private var showSearch = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    navigationPath = NavigationPath()
                                } label: {
                                    Image(systemName: "house")
                                }
                            }
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            navigationPath.append(NavigationDestination.searchResults)
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .accountList(let typeInfo):
            AccountListView(
                accountTypeInfo: typeInfo,
                navigationPath: $navigationPath
            )
        case .accountDetail(let pubkey, let accountData):
            AccountDetailView(
                pubkey: pubkey,
                preloadedData: accountData,
                navigationPath: $navigationPath
            )
        case .searchResults:
            SearchView(navigationPath: $navigationPath)
        }
    }
}
