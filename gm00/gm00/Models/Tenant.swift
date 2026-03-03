import Foundation

struct TenantBillingConfig: Hashable {
    let variant: UInt8
    let rate: UInt64
    let lastDeductionDzEpoch: UInt64
}

struct TenantAccount: Identifiable, Hashable {
    let accountType: UInt8
    let owner: String
    let bumpSeed: UInt8
    let code: String
    let vrfId: UInt16
    let referenceCount: UInt32
    let administrators: [String]
    let paymentStatus: TenantPaymentStatus
    let tokenAccount: String
    let metroRouting: Bool
    let routeLiveness: Bool
    let billing: TenantBillingConfig

    var pubkey: String = ""
    var id: String { pubkey }

    var searchableText: String {
        [code, pubkey].joined(separator: " ")
    }

    static func == (lhs: TenantAccount, rhs: TenantAccount) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension TenantAccount: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> TenantAccount {
        let accountType = try decoder.readU8()
        let owner = try decoder.readPubkey()
        let bumpSeed = try decoder.readU8()
        let code = try decoder.readString()
        let vrfId = try decoder.readU16()
        let referenceCount = try decoder.readU32()
        let administrators = try decoder.readPubkeyVec()
        let paymentStatusRaw = try decoder.readU8()
        let paymentStatus = TenantPaymentStatus(rawValue: paymentStatusRaw) ?? .delinquent
        let tokenAccount = try decoder.readPubkey()
        let metroRouting = try decoder.readBool()
        let routeLiveness = try decoder.readBool()
        let billingVariant = try decoder.readU8()
        let rate = try decoder.readU64()
        let lastDeductionDzEpoch = try decoder.readU64()
        let billing = TenantBillingConfig(variant: billingVariant, rate: rate, lastDeductionDzEpoch: lastDeductionDzEpoch)

        return TenantAccount(
            accountType: accountType, owner: owner, bumpSeed: bumpSeed,
            code: code, vrfId: vrfId, referenceCount: referenceCount,
            administrators: administrators, paymentStatus: paymentStatus,
            tokenAccount: tokenAccount, metroRouting: metroRouting,
            routeLiveness: routeLiveness, billing: billing
        )
    }
}
