import Foundation

enum ResolvedAccount {
    case location(String, LocationAccount)
    case exchange(String, ExchangeAccount)
    case device(String, DeviceAccount)
    case link(String, LinkAccount)
    case user(String, DZUser)
    case multicastGroup(String, MulticastGroupAccount)
    case contributor(String, ContributorAccount)
    case tenant(String, TenantAccount)
    case accessPass(String, AccessPassAccount)
    case reservation(String, ReservationAccount)

    var typeName: String {
        switch self {
        case .location: return "Location"
        case .exchange: return "Exchange"
        case .device: return "Device"
        case .link: return "Link"
        case .user: return "User"
        case .multicastGroup: return "Multicast Group"
        case .contributor: return "Contributor"
        case .tenant: return "Tenant"
        case .accessPass: return "Access Pass"
        case .reservation: return "Reservation"
        }
    }

    var pubkey: String {
        switch self {
        case .location(let pk, _): return pk
        case .exchange(let pk, _): return pk
        case .device(let pk, _): return pk
        case .link(let pk, _): return pk
        case .user(let pk, _): return pk
        case .multicastGroup(let pk, _): return pk
        case .contributor(let pk, _): return pk
        case .tenant(let pk, _): return pk
        case .accessPass(let pk, _): return pk
        case .reservation(let pk, _): return pk
        }
    }
}

class AccountResolver {
    private let rpcClient: SolanaRPCClient

    init(rpcClient: SolanaRPCClient) {
        self.rpcClient = rpcClient
    }

    func resolve(pubkey: String) async throws -> ResolvedAccount {
        let data = try await rpcClient.getAccountInfo(pubkey: pubkey)
        return try resolveFromData(pubkey: pubkey, data: data)
    }

    func resolveFromData(pubkey: String, data: Data) throws -> ResolvedAccount {
        guard !data.isEmpty else {
            throw RPCError.accountNotFound
        }

        let discriminator = data[data.startIndex]

        let decoder = BorshDecoder(data: data)

        switch discriminator {
        case AccountTypeDiscriminator.location:
            return .location(pubkey, try LocationAccount.decode(from: decoder))
        case AccountTypeDiscriminator.exchange:
            return .exchange(pubkey, try ExchangeAccount.decode(from: decoder))
        case AccountTypeDiscriminator.device:
            return .device(pubkey, try DeviceAccount.decode(from: decoder))
        case AccountTypeDiscriminator.link:
            return .link(pubkey, try LinkAccount.decode(from: decoder))
        case AccountTypeDiscriminator.user:
            return .user(pubkey, try DZUser.decode(from: decoder))
        case AccountTypeDiscriminator.multicastGroup:
            return .multicastGroup(pubkey, try MulticastGroupAccount.decode(from: decoder))
        case AccountTypeDiscriminator.contributor:
            return .contributor(pubkey, try ContributorAccount.decode(from: decoder))
        case AccountTypeDiscriminator.tenant:
            return .tenant(pubkey, try TenantAccount.decode(from: decoder))
        case AccountTypeDiscriminator.accessPass:
            return .accessPass(pubkey, try AccessPassAccount.decode(from: decoder))
        case AccountTypeDiscriminator.reservation:
            return .reservation(pubkey, try ReservationAccount.decode(from: decoder))
        default:
            throw RPCError.decodingError("Unknown account type discriminator: \(discriminator)")
        }
    }
}
