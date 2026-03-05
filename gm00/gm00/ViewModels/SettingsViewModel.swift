import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("selectedCluster") private var selectedClusterRaw: String = SolanaCluster.mainnetBeta.rawValue
    @AppStorage("customRPCURL") var customRPCURL: String = ""
    @AppStorage("customProgramId") var customProgramId: String = ""
    @AppStorage("useCustomRPC") var useCustomRPC: Bool = false

    @Published var connectionStatus: ConnectionStatus = .unknown
    @Published var isTestingConnection: Bool = false

    enum ConnectionStatus {
        case unknown, connected, failed(String)

        var displayText: String {
            switch self {
            case .unknown: return ""
            case .connected: return "Connected"
            case .failed(let msg): return "Failed: \(msg)"
            }
        }
    }

    var selectedCluster: SolanaCluster {
        get { SolanaCluster(rawValue: selectedClusterRaw) ?? .devnet }
        set { selectedClusterRaw = newValue.rawValue }
    }

    var isCustomURLSecure: Bool {
        guard let url = URL(string: customRPCURL),
              let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "https"
    }

    var currentRPCURL: URL {
        if useCustomRPC, let url = URL(string: customRPCURL) {
            return url
        }
        return selectedCluster.url
    }

    var currentProgramId: String {
        if useCustomRPC, !customProgramId.isEmpty {
            return customProgramId
        }
        return selectedCluster.programId
    }

    var displayEnvironment: String {
        if useCustomRPC {
            return "Custom"
        }
        return selectedCluster.displayName
    }

    func createRPCClient() -> SolanaRPCClient {
        if useCustomRPC,
           let url = URL(string: customRPCURL),
           url.scheme?.lowercased() == "https",
           !customProgramId.isEmpty {
            return SolanaRPCClient(url: url, programId: customProgramId)
        }
        return SolanaRPCClient(cluster: selectedCluster)
    }

    func testConnection() async {
        await MainActor.run { isTestingConnection = true }

        let client = createRPCClient()
        do {
            _ = try await client.getAccountsByType(AccountTypeDiscriminator.location)
            await MainActor.run {
                connectionStatus = .connected
                isTestingConnection = false
            }
        } catch {
            await MainActor.run {
                connectionStatus = .failed(error.localizedDescription)
                isTestingConnection = false
            }
        }
    }
}
