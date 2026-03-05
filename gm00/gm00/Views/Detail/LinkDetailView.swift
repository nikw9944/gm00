import SwiftUI

struct LinkDetailView: View {
    let pubkey: String
    let link: LinkAccount
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject private var telemetryViewModel = LinkTelemetryViewModel()

    @State private var sideACode: String?
    @State private var sideZCode: String?
    @State private var contributorCode: String?

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
                CodeLinkView(label: "Side A", pubkey: link.sideAPk, code: sideACode, navigationPath: $navigationPath)
                DetailRow(label: "Side A Interface", value: link.sideAIfaceName)
                CodeLinkView(label: "Side Z", pubkey: link.sideZPk, code: sideZCode, navigationPath: $navigationPath)
                DetailRow(label: "Side Z Interface", value: link.sideZIfaceName)
            }

            DetailSection(title: "Related Accounts") {
                CodeLinkView(label: "Contributor", pubkey: link.contributorPk, code: contributorCode, navigationPath: $navigationPath)
            }
        }
        .task {
            let rpcClient = settingsViewModel.createRPCClient()
            async let telemetryTask: () = telemetryViewModel.loadTelemetry(
                linkPk: pubkey,
                sideAPk: link.sideAPk,
                sideZPk: link.sideZPk,
                rpcClient: rpcClient,
                cluster: settingsViewModel.selectedCluster
            )
            async let codesTask: () = loadRelatedCodes(rpcClient: rpcClient)
            _ = await (try? telemetryTask, codesTask)
        }
    }

    private func loadRelatedCodes(rpcClient: SolanaRPCClient) async {
        let pubkeys = [link.sideAPk, link.sideZPk, link.contributorPk]
        let validPubkeys = pubkeys.filter { !$0.allSatisfy { $0 == "1" } }
        guard !validPubkeys.isEmpty else { return }

        do {
            let results = try await rpcClient.getMultipleAccounts(pubkeys: validPubkeys)
            let lookup = Dictionary(uniqueKeysWithValues: results.map { ($0.pubkey, $0.data) })

            if let data = lookup[link.sideAPk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let device = try? DeviceAccount.decode(from: decoder) {
                    sideACode = device.code
                }
            }
            if let data = lookup[link.sideZPk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let device = try? DeviceAccount.decode(from: decoder) {
                    sideZCode = device.code
                }
            }
            if let data = lookup[link.contributorPk] ?? nil {
                let decoder = BorshDecoder(data: data)
                if let contrib = try? ContributorAccount.decode(from: decoder) {
                    contributorCode = contrib.code
                }
            }
        } catch {
            // Codes remain nil — falls back to truncated pubkey
        }
    }
}
