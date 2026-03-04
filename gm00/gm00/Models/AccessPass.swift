import Foundation

struct AccessPassAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let bumpSeed: UInt8
    let accessPassType: AccessPassType
    let clientIp: String
    let userPayer: String
    let lastAccessEpoch: UInt64
    let connectionCount: UInt16
    let status: AccessPassStatus
    let mgroupPubAllowlist: [String]
    let mgroupSubAllowlist: [String]
    let flags: UInt8
    let tenantAllowlist: [String]

    var pubkey: String = ""
    var id: String { pubkey }

    var isDynamic: Bool { flags & 0x01 != 0 }
    var allowMultipleIp: Bool { flags & 0x02 != 0 }

    var searchableText: String {
        [clientIp, pubkey, accessPassType.displayName].joined(separator: " ")
    }

    static func == (lhs: AccessPassAccount, rhs: AccessPassAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension AccessPassAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> AccessPassAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let bumpSeed = try decoder.readU8()

        let apTypeVariant = try decoder.readU8()
        let accessPassType: AccessPassType
        switch apTypeVariant {
        case 0: accessPassType = .prepaid
        case 1: accessPassType = .solanaValidator(try decoder.readPubkey())
        case 2: accessPassType = .solanaRPC(try decoder.readPubkey())
        case 3: accessPassType = .solanaMulticastPublisher(try decoder.readPubkey())
        case 4: accessPassType = .solanaMulticastSubscriber(try decoder.readPubkey())
        case 5: accessPassType = .others(try decoder.readString(), try decoder.readString())
        default: throw BorshDecoderError.invalidEnumVariant(apTypeVariant)
        }

        let clientIp = try decoder.readIPv4()
        let userPayer = try decoder.readPubkey()
        let lastAccessEpoch = try decoder.readU64()
        let connectionCount = try decoder.readU16()
        let statusRaw = try decoder.readU8()
        let status = AccessPassStatus(rawValue: statusRaw) ?? .requested
        let mgroupPubAllowlist = try decoder.readPubkeyVec()
        let mgroupSubAllowlist = try decoder.readPubkeyVec()
        let flags = try decoder.readU8()
        let tenantAllowlist = try decoder.readPubkeyVec()

        return AccessPassAccount(
            accountType: accountType, owner: owner, bumpSeed: bumpSeed,
            accessPassType: accessPassType, clientIp: clientIp,
            userPayer: userPayer, lastAccessEpoch: lastAccessEpoch,
            connectionCount: connectionCount, status: status,
            mgroupPubAllowlist: mgroupPubAllowlist,
            mgroupSubAllowlist: mgroupSubAllowlist,
            flags: flags, tenantAllowlist: tenantAllowlist
        )
    }
}
