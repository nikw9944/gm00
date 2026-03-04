import SwiftUI

struct DeviceDetailView: View {
    let pubkey: String
    let device: DeviceAccount
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSection(title: "Identity") {
                DetailRow(label: "Code", value: device.code)
                DetailRow(label: "Pubkey", value: pubkey, monospaced: true)
                DetailRow(label: "Type", value: device.deviceType.displayName)
            }

            DetailSection(title: "Status") {
                HStack {
                    Text("Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.status.displayName)
                }
                HStack {
                    Text("Health")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.deviceHealth.displayName)
                }
                HStack {
                    Text("Desired Status")
                        .foregroundColor(.secondary)
                    Spacer()
                    StatusBadgeView(device.desiredStatus.displayName)
                }
            }

            DetailSection(title: "Network") {
                IPAddressView(label: "Public IP", ip: device.publicIp)
                DetailRow(label: "Mgmt VRF", value: device.mgmtVrf)
                if !device.dzPrefixes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DZ Prefixes")
                            .foregroundColor(.secondary)
                        ForEach(device.dzPrefixes, id: \.description) { prefix in
                            Text(prefix.description)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }

            DetailSection(title: "Capacity") {
                DetailRow(label: "Users", value: "\(device.usersCount) / \(device.maxUsers)")
                DetailRow(label: "Unicast Users", value: "\(device.unicastUsersCount) / \(device.maxUnicastUsers)")
                DetailRow(label: "Multicast Users", value: "\(device.multicastUsersCount) / \(device.maxMulticastUsers)")
                DetailRow(label: "Reserved Seats", value: "\(device.reservedSeats)")
                DetailRow(label: "Reference Count", value: "\(device.referenceCount)")
            }

            DetailSection(title: "Related Accounts") {
                PubkeyLinkView(label: "Location", pubkey: device.locationPk, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Exchange", pubkey: device.exchangePk, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Contributor", pubkey: device.contributorPk, navigationPath: $navigationPath)
                PubkeyLinkView(label: "Metrics Publisher", pubkey: device.metricsPublisherPk, navigationPath: $navigationPath)
            }

            if !device.interfaces.isEmpty {
                DetailSection(title: "Interfaces (\(device.interfaces.count))") {
                    ForEach(Array(device.interfaces.enumerated()), id: \.offset) { _, iface in
                        InterfaceRow(iface: iface)
                        Divider()
                    }
                }
            }
        }
    }
}

struct InterfaceRow: View {
    let iface: Interface
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 4) {
                switch iface {
                case .v1(let v1):
                    DetailRow(label: "Version", value: "V1")
                    HStack { Text("Status").foregroundColor(.secondary); Spacer(); StatusBadgeView(v1.status.displayName) }
                    DetailRow(label: "Type", value: v1.interfaceType.displayName)
                    DetailRow(label: "Loopback", value: v1.loopbackType.displayName)
                    DetailRow(label: "VLAN", value: "\(v1.vlanId)")
                    DetailRow(label: "IP Net", value: v1.ipNet.description)
                    DetailRow(label: "Segment Idx", value: "\(v1.nodeSegmentIdx)")
                    DetailRow(label: "Tunnel Endpoint", value: v1.userTunnelEndpoint ? "Yes" : "No")
                case .v2(let v2):
                    DetailRow(label: "Version", value: "V2")
                    HStack { Text("Status").foregroundColor(.secondary); Spacer(); StatusBadgeView(v2.status.displayName) }
                    DetailRow(label: "Type", value: v2.interfaceType.displayName)
                    DetailRow(label: "CYOA", value: v2.interfaceCyoa.displayName)
                    DetailRow(label: "DIA", value: v2.interfaceDia.displayName)
                    DetailRow(label: "Loopback", value: v2.loopbackType.displayName)
                    DetailRow(label: "Bandwidth", value: v2.bandwidth.formattedBandwidth)
                    DetailRow(label: "CIR", value: v2.cir.formattedBandwidth)
                    DetailRow(label: "MTU", value: "\(v2.mtu)")
                    DetailRow(label: "Routing", value: v2.routingMode.displayName)
                    DetailRow(label: "VLAN", value: "\(v2.vlanId)")
                    DetailRow(label: "IP Net", value: v2.ipNet.description)
                    DetailRow(label: "Segment Idx", value: "\(v2.nodeSegmentIdx)")
                    DetailRow(label: "Tunnel Endpoint", value: v2.userTunnelEndpoint ? "Yes" : "No")
                }
            }
        } label: {
            HStack {
                Text(iface.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                StatusBadgeView(iface.status.displayName)
            }
        }
    }
}
