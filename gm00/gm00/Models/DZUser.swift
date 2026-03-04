import Foundation

struct DZUser: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let userType: UserType
    let tenantPk: String
    let devicePk: String
    let cyoaType: UserCYOA
    let clientIp: String
    let dzIp: String
    let tunnelId: UInt16
    let tunnelNet: NetworkV4
    let status: UserStatus
    let publishers: [String]
    let subscribers: [String]
    let validatorPubkey: String
    let tunnelEndpoint: String

    var pubkey: String = ""
    var displayCode: String?
    var id: String { pubkey }

    var sortKey: String { displayCode ?? pubkey }

    var searchableText: String {
        [displayCode, clientIp, dzIp, pubkey, validatorPubkey].compactMap { $0 }.joined(separator: " ")
    }

    static func == (lhs: DZUser, rhs: DZUser) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension DZUser: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> DZUser {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let userTypeRaw = try decoder.readU8()
        let userType = UserType(rawValue: userTypeRaw) ?? .ibrl
        let tenantPk = try decoder.readPubkey()
        let devicePk = try decoder.readPubkey()
        let cyoaTypeRaw = try decoder.readU8()
        let cyoaType = UserCYOA(rawValue: cyoaTypeRaw) ?? .none
        let clientIp = try decoder.readIPv4()
        let dzIp = try decoder.readIPv4()
        let tunnelId = try decoder.readU16()
        let tunnelNet = try decoder.readNetworkV4()
        let statusRaw = try decoder.readU8()
        let status = UserStatus(rawValue: statusRaw) ?? .pending
        let publishers = try decoder.readPubkeyVec()
        let subscribers = try decoder.readPubkeyVec()
        let validatorPubkey = try decoder.readPubkey()
        let tunnelEndpoint = try decoder.readIPv4()

        return DZUser(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, userType: userType, tenantPk: tenantPk,
            devicePk: devicePk, cyoaType: cyoaType, clientIp: clientIp,
            dzIp: dzIp, tunnelId: tunnelId, tunnelNet: tunnelNet,
            status: status, publishers: publishers, subscribers: subscribers,
            validatorPubkey: validatorPubkey, tunnelEndpoint: tunnelEndpoint
        )
    }
}
