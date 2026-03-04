import Foundation

struct MulticastGroupAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let tenantPk: String
    let multicastIp: String
    let maxBandwidth: UInt64
    let status: MulticastGroupStatus
    let code: String
    let publisherCount: UInt32
    let subscriberCount: UInt32

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, multicastIp, pubkey].joined(separator: " ")
    }

    static func == (lhs: MulticastGroupAccount, rhs: MulticastGroupAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension MulticastGroupAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> MulticastGroupAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let tenantPk = try decoder.readPubkey()
        let multicastIp = try decoder.readIPv4()
        let maxBandwidth = try decoder.readU64()
        let statusRaw = try decoder.readU8()
        let status = MulticastGroupStatus(rawValue: statusRaw) ?? .pending
        let code = try decoder.readString()
        let publisherCount = try decoder.readU32()
        let subscriberCount = try decoder.readU32()

        return MulticastGroupAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, tenantPk: tenantPk, multicastIp: multicastIp,
            maxBandwidth: maxBandwidth, status: status, code: code,
            publisherCount: publisherCount, subscriberCount: subscriberCount
        )
    }
}
