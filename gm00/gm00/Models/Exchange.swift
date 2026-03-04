import Foundation

struct ExchangeAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let lat: Double
    let lng: Double
    let bgpCommunity: UInt16
    let unused: UInt16
    let status: ExchangeStatus
    let code: String
    let name: String
    let referenceCount: UInt32
    let device1Pk: String
    let device2Pk: String

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, name, pubkey].joined(separator: " ")
    }

    static func == (lhs: ExchangeAccount, rhs: ExchangeAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension ExchangeAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> ExchangeAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let lat = try decoder.readF64()
        let lng = try decoder.readF64()
        let bgpCommunity = try decoder.readU16()
        let unused = try decoder.readU16()
        let statusRaw = try decoder.readU8()
        let status = ExchangeStatus(rawValue: statusRaw) ?? .pending
        let code = try decoder.readString()
        let name = try decoder.readString()
        let referenceCount = try decoder.readU32()
        let device1Pk = try decoder.readPubkey()
        let device2Pk = try decoder.readPubkey()

        return ExchangeAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, lat: lat, lng: lng, bgpCommunity: bgpCommunity,
            unused: unused, status: status, code: code, name: name,
            referenceCount: referenceCount, device1Pk: device1Pk, device2Pk: device2Pk
        )
    }
}
