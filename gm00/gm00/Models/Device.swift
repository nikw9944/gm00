import Foundation

struct InterfaceV1: Hashable {
    let status: InterfaceStatus
    let name: String
    let interfaceType: InterfaceType
    let loopbackType: LoopbackType
    let vlanId: UInt16
    let ipNet: NetworkV4
    let nodeSegmentIdx: UInt16
    let userTunnelEndpoint: Bool
}

struct InterfaceV2: Hashable {
    let status: InterfaceStatus
    let name: String
    let interfaceType: InterfaceType
    let interfaceCyoa: InterfaceCYOA
    let interfaceDia: InterfaceDIA
    let loopbackType: LoopbackType
    let bandwidth: UInt64
    let cir: UInt64
    let mtu: UInt16
    let routingMode: RoutingMode
    let vlanId: UInt16
    let ipNet: NetworkV4
    let nodeSegmentIdx: UInt16
    let userTunnelEndpoint: Bool
}

enum Interface: Hashable {
    case v1(InterfaceV1)
    case v2(InterfaceV2)

    var name: String {
        switch self {
        case .v1(let iface): return iface.name
        case .v2(let iface): return iface.name
        }
    }

    var status: InterfaceStatus {
        switch self {
        case .v1(let iface): return iface.status
        case .v2(let iface): return iface.status
        }
    }
}

extension Interface: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> Interface {
        let variant = try decoder.readU8()
        switch variant {
        case 0:
            let status = InterfaceStatus(rawValue: try decoder.readU8()) ?? .invalid
            let name = try decoder.readString()
            let interfaceType = InterfaceType(rawValue: try decoder.readU8()) ?? .invalid
            let loopbackType = LoopbackType(rawValue: try decoder.readU8()) ?? .none
            let vlanId = try decoder.readU16()
            let ipNet = try decoder.readNetworkV4()
            let nodeSegmentIdx = try decoder.readU16()
            let userTunnelEndpoint = try decoder.readBool()
            return .v1(InterfaceV1(
                status: status, name: name, interfaceType: interfaceType,
                loopbackType: loopbackType, vlanId: vlanId, ipNet: ipNet,
                nodeSegmentIdx: nodeSegmentIdx, userTunnelEndpoint: userTunnelEndpoint
            ))
        case 1:
            let status = InterfaceStatus(rawValue: try decoder.readU8()) ?? .invalid
            let name = try decoder.readString()
            let interfaceType = InterfaceType(rawValue: try decoder.readU8()) ?? .invalid
            let interfaceCyoa = InterfaceCYOA(rawValue: try decoder.readU8()) ?? .none
            let interfaceDia = InterfaceDIA(rawValue: try decoder.readU8()) ?? .none
            let loopbackType = LoopbackType(rawValue: try decoder.readU8()) ?? .none
            let bandwidth = try decoder.readU64()
            let cir = try decoder.readU64()
            let mtu = try decoder.readU16()
            let routingMode = RoutingMode(rawValue: try decoder.readU8()) ?? .static
            let vlanId = try decoder.readU16()
            let ipNet = try decoder.readNetworkV4()
            let nodeSegmentIdx = try decoder.readU16()
            let userTunnelEndpoint = try decoder.readBool()
            return .v2(InterfaceV2(
                status: status, name: name, interfaceType: interfaceType,
                interfaceCyoa: interfaceCyoa, interfaceDia: interfaceDia,
                loopbackType: loopbackType, bandwidth: bandwidth, cir: cir,
                mtu: mtu, routingMode: routingMode, vlanId: vlanId, ipNet: ipNet,
                nodeSegmentIdx: nodeSegmentIdx, userTunnelEndpoint: userTunnelEndpoint
            ))
        default:
            throw BorshDecoderError.invalidEnumVariant(variant)
        }
    }
}

struct DeviceAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let locationPk: String
    let exchangePk: String
    let deviceType: DeviceType
    let publicIp: String
    let status: DeviceStatus
    let code: String
    let dzPrefixes: [NetworkV4]
    let metricsPublisherPk: String
    let contributorPk: String
    let mgmtVrf: String
    let interfaces: [Interface]
    let referenceCount: UInt32
    let usersCount: UInt16
    let maxUsers: UInt16
    let deviceHealth: DeviceHealth
    let desiredStatus: DeviceDesiredStatus
    let unicastUsersCount: UInt16
    let multicastUsersCount: UInt16
    let maxUnicastUsers: UInt16
    let maxMulticastUsers: UInt16
    let reservedSeats: UInt16

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, publicIp, pubkey, mgmtVrf].joined(separator: " ")
    }

    static func == (lhs: DeviceAccount, rhs: DeviceAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension DeviceAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> DeviceAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let locationPk = try decoder.readPubkey()
        let exchangePk = try decoder.readPubkey()
        let deviceTypeRaw = try decoder.readU8()
        let deviceType = DeviceType(rawValue: deviceTypeRaw) ?? .hybrid
        let publicIp = try decoder.readIPv4()
        let statusRaw = try decoder.readU8()
        let status = DeviceStatus(rawValue: statusRaw) ?? .pending
        let code = try decoder.readString()
        let dzPrefixes = try decoder.readNetworkV4List()
        let metricsPublisherPk = try decoder.readPubkey()
        let contributorPk = try decoder.readPubkey()
        let mgmtVrf = try decoder.readString()
        let interfaces = try decoder.readVec { try Interface.decode(from: decoder) }
        let referenceCount = try decoder.readU32()
        let usersCount = try decoder.readU16()
        let maxUsers = try decoder.readU16()
        let deviceHealthRaw = try decoder.readU8()
        let deviceHealth = DeviceHealth(rawValue: deviceHealthRaw) ?? .unknown
        let desiredStatusRaw = try decoder.readU8()
        let desiredStatus = DeviceDesiredStatus(rawValue: desiredStatusRaw) ?? .pending
        let unicastUsersCount = try decoder.readU16()
        let multicastUsersCount = try decoder.readU16()
        let maxUnicastUsers = try decoder.readU16()
        let maxMulticastUsers = try decoder.readU16()
        let reservedSeats: UInt16 = decoder.remaining >= 2 ? try decoder.readU16() : 0

        return DeviceAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, locationPk: locationPk, exchangePk: exchangePk,
            deviceType: deviceType, publicIp: publicIp, status: status,
            code: code, dzPrefixes: dzPrefixes, metricsPublisherPk: metricsPublisherPk,
            contributorPk: contributorPk, mgmtVrf: mgmtVrf, interfaces: interfaces,
            referenceCount: referenceCount, usersCount: usersCount, maxUsers: maxUsers,
            deviceHealth: deviceHealth, desiredStatus: desiredStatus,
            unicastUsersCount: unicastUsersCount, multicastUsersCount: multicastUsersCount,
            maxUnicastUsers: maxUnicastUsers, maxMulticastUsers: maxMulticastUsers,
            reservedSeats: reservedSeats
        )
    }
}
