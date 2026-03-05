import SwiftUI

struct LinkDetailView: View {
    let pubkey: String
    let link: LinkAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var telemetryViewModel = LinkTelemetryViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: link.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                DetailRow(label: "Type", value: link.linkType.displayName)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(link.status.displayName)
                }
                HStack {
                    Text("Health")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(link.linkHealth.displayName)
                }
                HStack {
                    Text("Desired Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(link.desiredStatus.displayName)
                }
            }

            DetailSection(title: "Performance") {
                DetailRow(label: "Bandwidth", value: link.bandwidth.formattedBandwidth)
                DetailRow(label: "MTU", value: "\(link.mtu)")
                DetailRow(label: "Delay", value: link.delayNs.formattedDelay)
                DetailRow(label: "Jitter", value: link.jitterNs.formattedDelay)
                DetailRow(label: "Delay Override", value: link.delayOverrideNs.formattedDelay)
            }

            TelemetryChartsSection(viewModel: telemetryViewModel, onRetry: {
                Task {
                    let rpcClient = settingsViewModel.createRPCClient()
                    await telemetryViewModel.loadTelemetry(
                        linkPk: pubkey,
                        sideAPk: link.sideAPk,
                        sideZPk: link.sideZPk,
                        rpcClient: rpcClient,
                        cluster: settingsViewModel.selectedCluster
                    )
                }
            })

            DetailSection(title: "Tunnel") {
                DetailRow(label: "Tunnel ID", value: "\(link.tunnelId)")
                DetailRow(label: "Tunnel Net", value: link.tunnelNet.description)
            }

            DetailSection(title: "Endpoints") {
                PubkeyLinkView(label: "Side A", pubkey: link.sideAPk, navigationPath: $navigationPath)
                DetailRow(label: "Side A Interface", value: link.sideAIfaceName)
                PubkeyLinkView(label: "Side Z", pubkey: link.sideZPk, navigationPath: $navigationPath)
                DetailRow(label: "Side Z Interface", value: link.sideZIfaceName)
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Contributor", pubkey: link.contributorPk, navigationPath: $navigationPath)
            }
        }
        .task {
            let rpcClient = settingsViewModel.createRPCClient()
            await telemetryViewModel.loadTelemetry(
                linkPk: pubkey,
                sideAPk: link.sideAPk,
                sideZPk: link.sideZPk,
                rpcClient: rpcClient,
                cluster: settingsViewModel.selectedCluster
            )
        }
    }
}
