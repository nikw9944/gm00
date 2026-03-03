import Foundation

struct ContributorAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let status: ContributorStatus
    let code: String
    let referenceCount: UInt32
    let opsManagerPk: String

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, pubkey].joined(separator: " ")
    }

    static func == (lhs: ContributorAccount, rhs: ContributorAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension ContributorAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> ContributorAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let statusRaw = try decoder.readU8()
        let status = ContributorStatus(rawValue: statusRaw) ?? .none
        let code = try decoder.readString()
        let referenceCount = try decoder.readU32()
        let opsManagerPk = try decoder.readPubkey()

        return ContributorAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, status: status, code: code,
            referenceCount: referenceCount, opsManagerPk: opsManagerPk
        )
    }
}
