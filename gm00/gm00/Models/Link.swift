import Foundation

struct LinkAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let index: (high: UInt64, low: UInt64)
    let bumpSeed: UInt8
    let sideAPk: String
    let sideZPk: String
    let linkType: LinkLinkType
    let bandwidth: UInt64
    let mtu: UInt32
    let delayNs: UInt64
    let jitterNs: UInt64
    let tunnelId: UInt16
    let tunnelNet: NetworkV4
    let status: LinkStatus
    let code: String
    let contributorPk: String
    let sideAIfaceName: String
    let sideZIfaceName: String
    let delayOverrideNs: UInt64
    let linkHealth: LinkHealth
    let desiredStatus: LinkDesiredStatus

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, pubkey, sideAIfaceName, sideZIfaceName].joined(separator: " ")
    }

    static func == (lhs: LinkAccount, rhs: LinkAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension LinkAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> LinkAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let index = try decoder.readU128()
        let bumpSeed = try decoder.readU8()
        let sideAPk = try decoder.readPubkey()
        let sideZPk = try decoder.readPubkey()
        let linkTypeRaw = try decoder.readU8()
        let linkType = LinkLinkType(rawValue: linkTypeRaw) ?? .wan
        let bandwidth = try decoder.readU64()
        let mtu = try decoder.readU32()
        let delayNs = try decoder.readU64()
        let jitterNs = try decoder.readU64()
        let tunnelId = try decoder.readU16()
        let tunnelNet = try decoder.readNetworkV4()
        let statusRaw = try decoder.readU8()
        let status = LinkStatus(rawValue: statusRaw) ?? .pending
        let code = try decoder.readString()
        let contributorPk = try decoder.readPubkey()
        let sideAIfaceName = try decoder.readString()
        let sideZIfaceName = try decoder.readString()
        let delayOverrideNs = try decoder.readU64()
        let linkHealthRaw = try decoder.readU8()
        let linkHealth = LinkHealth(rawValue: linkHealthRaw) ?? .unknown
        let desiredStatusRaw = try decoder.readU8()
        let desiredStatus = LinkDesiredStatus(rawValue: desiredStatusRaw) ?? .pending

        return LinkAccount(
            accountType: accountType, owner: owner, index: index,
            bumpSeed: bumpSeed, sideAPk: sideAPk, sideZPk: sideZPk,
            linkType: linkType, bandwidth: bandwidth, mtu: mtu,
            delayNs: delayNs, jitterNs: jitterNs, tunnelId: tunnelId,
            tunnelNet: tunnelNet, status: status, code: code,
            contributorPk: contributorPk, sideAIfaceName: sideAIfaceName,
            sideZIfaceName: sideZIfaceName, delayOverrideNs: delayOverrideNs,
            linkHealth: linkHealth, desiredStatus: desiredStatus
        )
    }
}
