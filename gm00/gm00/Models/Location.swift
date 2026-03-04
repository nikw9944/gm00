import Foundation

struct LocationAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let lat: Double
    let lng: Double
    let locId: UInt32
    let status: LocationStatus
    let code: String
    let name: String
    let country: String
    let referenceCount: UInt32

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, name, country, pubkey].joined(separator: " ")
    }

    static func == (lhs: LocationAccount, rhs: LocationAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension LocationAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> LocationAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let lat = try decoder.readF64()
        let lng = try decoder.readF64()
        let locId = try decoder.readU32()
        let statusRaw = try decoder.readU8()
        let status = LocationStatus(rawValue: statusRaw) ?? .pending
        let code = try decoder.readString()
        let name = try decoder.readString()
        let country = try decoder.readString()
        let referenceCount = try decoder.readU32()

        return LocationAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, lat: lat, lng: lng, locId: locId,
            status: status, code: code, name: name, country: country,
            referenceCount: referenceCount
        )
    }
}
