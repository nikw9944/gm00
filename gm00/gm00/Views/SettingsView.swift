import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Environment") {
                    Picker("Cluster", selection: $settingsViewModel.selectedCluster) {
                        ForEach(SolanaCluster.allCases) { cluster in
                            Text(cluster.displayName).tag(cluster)
                        }
                    }
                    .disabled(settingsViewModel.useCustomRPC)
                }

                Section("Custom RPC") {
                    Toggle("Use Custom RPC", isOn: $settingsViewModel.useCustomRPC)

                    if settingsViewModel.useCustomRPC {
                        TextField("RPC URL (HTTPS)", text: $settingsViewModel.customRPCURL)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .keyboardType(.URL)

                        if !settingsViewModel.customRPCURL.isEmpty && !settingsViewModel.isCustomURLSecure {
                            Text("HTTPS is required for custom RPC endpoints")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        TextField("Program ID", text: $settingsViewModel.customProgramId)
                            .autocapitalization(.none)
                    }
                }

                Section("Connection") {
                    HStack {
                        Text("Status")
                        Spacer()
                        if settingsViewModel.isTestingConnection {
                            ProgressView()
                        } else {
                            Text(settingsViewModel.connectionStatus.displayText)
                                .foregroundColor(
                                    settingsViewModel.connectionStatus.displayText == "Connected"
                                    ? .green : .red
                                )
                        }
                    }

                    Button("Test Connection") {
                        Task { await settingsViewModel.testConnection() }
                    }
                    .disabled(settingsViewModel.isTestingConnection)
                }

                Section("About") {
                    HStack {
                        Text("Program ID")
                        Spacer()
                        Text(settingsViewModel.currentProgramId.truncatedPubkey)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("RPC URL")
                        Spacer()
                        Text(settingsViewModel.currentRPCURL.absoluteString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
