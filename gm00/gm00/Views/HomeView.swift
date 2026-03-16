import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var navigationPath: NavigationPath

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(settingsViewModel.displayEnvironment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AccountTypeInfo.browsableTypes) { typeInfo in
                        Button {
                            navigationPath.append(NavigationDestination.accountList(typeInfo))
                        } label: {
                            AccountTypeCard(
                                typeInfo: typeInfo,
                                count: homeViewModel.accountCounts[typeInfo.id]
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("gm00")
        .task(id: settingsViewModel.displayEnvironment) {
            await homeViewModel.loadCounts(client: settingsViewModel.createRPCClient())
        }
    }
}

struct AccountTypeCard: View {
    let typeInfo: AccountTypeInfo
    var count: Int?

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: typeInfo.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            Text(count.map { "\($0) \(typeInfo.name)" } ?? typeInfo.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(typeInfo.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
