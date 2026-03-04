import Foundation

struct ReservationAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let bumpSeed: UInt8
    let devicePk: String
    let clientIp: String

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [clientIp, pubkey].joined(separator: " ")
    }

    static func == (lhs: ReservationAccount, rhs: ReservationAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension ReservationAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> ReservationAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let bumpSeed = try decoder.readU8()
        let devicePk = try decoder.readPubkey()
        let clientIp = try decoder.readIPv4()

        return ReservationAccount(
            accountType: accountType, owner: owner,
            bumpSeed: bumpSeed, devicePk: devicePk, clientIp: clientIp
        )
    }
}
