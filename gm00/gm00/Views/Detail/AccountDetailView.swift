import SwiftUI

struct AccountDetailView: View {
    let pubkey: String
    let preloadedData: Data?
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel = AccountDetailViewModel()

    init(pubkey: String, preloadedData: Data?, navigationPath: Binding<NavigationPath>) {
        self.pubkey = pubkey
        self.preloadedData = preloadedData
        self._navigationPath = navigationPath
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading account...")
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
                            await viewModel.loadAccount(pubkey: pubkey, preloadedData: preloadedData)
                        }
                    }
                }
                .padding()
            } else if let account = viewModel.resolvedAccount {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        detailContent(for: account)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.resolvedAccount?.typeName ?? "Account")
        .task {
            viewModel.rpcClient = settingsViewModel.createRPCClient()
            await viewModel.loadAccount(pubkey: pubkey, preloadedData: preloadedData)
        }
    }

    @ViewBuilder
    private func detailContent(for account: ResolvedAccount) -> some View {
        switch account {
        case .location(let pk, let loc):
            LocationDetailView(pubkey: pk, location: loc, navigationPath: $navigationPath)
        case .exchange(let pk, let ex):
            ExchangeDetailView(pubkey: pk, exchange: ex, navigationPath: $navigationPath)
        case .device(let pk, let dev):
            DeviceDetailView(pubkey: pk, device: dev, navigationPath: $navigationPath)
        case .link(let pk, let link):
            LinkDetailView(pubkey: pk, link: link, navigationPath: $navigationPath)
        case .user(let pk, let user):
            UserDetailView(pubkey: pk, user: user, navigationPath: $navigationPath)
        case .multicastGroup(let pk, let mg):
            MulticastGroupDetailView(pubkey: pk, multicastGroup: mg, navigationPath: $navigationPath)
        case .contributor(let pk, let contrib):
            ContributorDetailView(pubkey: pk, contributor: contrib, navigationPath: $navigationPath)
        case .tenant(let pk, let tenant):
            TenantDetailView(pubkey: pk, tenant: tenant, navigationPath: $navigationPath)
        case .accessPass(let pk, let ap):
            AccessPassDetailView(pubkey: pk, accessPass: ap, navigationPath: $navigationPath)
        case .reservation(let pk, let res):
            ReservationDetailView(pubkey: pk, reservation: res, navigationPath: $navigationPath)
        }
    }
}
