import Foundation

enum LocationStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case suspended = 2

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .suspended: return "Suspended"
        }
    }
}

enum ExchangeStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case suspended = 2

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .suspended: return "Suspended"
        }
    }
}

enum DeviceType: UInt8, CaseIterable {
    case hybrid = 0
    case transit = 1
    case edge = 2

    var displayName: String {
        switch self {
        case .hybrid: return "Hybrid"
        case .transit: return "Transit"
        case .edge: return "Edge"
        }
    }
}

enum DeviceStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case deleting = 3
    case rejected = 4
    case drained = 5
    case deviceProvisioning = 6
    case linkProvisioning = 7

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .deleting: return "Deleting"
        case .rejected: return "Rejected"
        case .drained: return "Drained"
        case .deviceProvisioning: return "Device Provisioning"
        case .linkProvisioning: return "Link Provisioning"
        }
    }
}

enum DeviceHealth: UInt8, CaseIterable {
    case unknown = 0
    case pending = 1
    case readyForLinks = 2
    case readyForUsers = 3
    case impaired = 4

    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .pending: return "Pending"
        case .readyForLinks: return "Ready for Links"
        case .readyForUsers: return "Ready for Users"
        case .impaired: return "Impaired"
        }
    }
}

enum DeviceDesiredStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case drained = 6

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .drained: return "Drained"
        }
    }
}

enum LinkLinkType: UInt8, CaseIterable {
    case wan = 1
    case dzx = 127

    var displayName: String {
        switch self {
        case .wan: return "WAN"
        case .dzx: return "DZX"
        }
    }
}

enum LinkStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case deleting = 3
    case rejected = 4
    case requested = 5
    case hardDrained = 6
    case softDrained = 7
    case provisioning = 8

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .deleting: return "Deleting"
        case .rejected: return "Rejected"
        case .requested: return "Requested"
        case .hardDrained: return "Hard Drained"
        case .softDrained: return "Soft Drained"
        case .provisioning: return "Provisioning"
        }
    }
}

enum LinkHealth: UInt8, CaseIterable {
    case unknown = 0
    case pending = 1
    case readyForService = 2
    case impaired = 3

    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .pending: return "Pending"
        case .readyForService: return "Ready for Service"
        case .impaired: return "Impaired"
        }
    }
}

enum LinkDesiredStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case hardDrained = 6
    case softDrained = 7

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .hardDrained: return "Hard Drained"
        case .softDrained: return "Soft Drained"
        }
    }
}

enum UserType: UInt8, CaseIterable {
    case ibrl = 0
    case ibrlWithAllocatedIP = 1
    case edgeFiltering = 2
    case multicast = 3

    var displayName: String {
        switch self {
        case .ibrl: return "IBRL"
        case .ibrlWithAllocatedIP: return "IBRL (Allocated IP)"
        case .edgeFiltering: return "Edge Filtering"
        case .multicast: return "Multicast"
        }
    }
}

enum UserCYOA: UInt8, CaseIterable {
    case none = 0
    case greOverDIA = 1
    case greOverFabric = 2
    case greOverPrivatePeering = 3
    case greOverPublicPeering = 4
    case greOverCable = 5

    var displayName: String {
        switch self {
        case .none: return "None"
        case .greOverDIA: return "GRE over DIA"
        case .greOverFabric: return "GRE over Fabric"
        case .greOverPrivatePeering: return "GRE over Private Peering"
        case .greOverPublicPeering: return "GRE over Public Peering"
        case .greOverCable: return "GRE over Cable"
        }
    }
}

enum UserStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case suspendedDeprecated = 2
    case deleting = 3
    case rejected = 4
    case pendingBan = 5
    case banned = 6
    case updating = 7
    case outOfCredits = 8

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .suspendedDeprecated: return "Suspended (Deprecated)"
        case .deleting: return "Deleting"
        case .rejected: return "Rejected"
        case .pendingBan: return "Pending Ban"
        case .banned: return "Banned"
        case .updating: return "Updating"
        case .outOfCredits: return "Out of Credits"
        }
    }
}

enum MulticastGroupStatus: UInt8, CaseIterable {
    case pending = 0
    case activated = 1
    case suspended = 2
    case deleting = 3
    case rejected = 4

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .suspended: return "Suspended"
        case .deleting: return "Deleting"
        case .rejected: return "Rejected"
        }
    }
}

enum ContributorStatus: UInt8, CaseIterable {
    case none = 0
    case activated = 1
    case suspended = 2
    case deleting = 3

    var displayName: String {
        switch self {
        case .none: return "None"
        case .activated: return "Activated"
        case .suspended: return "Suspended"
        case .deleting: return "Deleting"
        }
    }
}

enum TenantPaymentStatus: UInt8, CaseIterable {
    case delinquent = 0
    case paid = 1

    var displayName: String {
        switch self {
        case .delinquent: return "Delinquent"
        case .paid: return "Paid"
        }
    }
}

enum AccessPassType {
    case prepaid
    case solanaValidator(String)
    case solanaRPC(String)
    case solanaMulticastPublisher(String)
    case solanaMulticastSubscriber(String)
    case others(String, String)

    var displayName: String {
        switch self {
        case .prepaid: return "Prepaid"
        case .solanaValidator: return "Solana Validator"
        case .solanaRPC: return "Solana RPC"
        case .solanaMulticastPublisher: return "Multicast Publisher"
        case .solanaMulticastSubscriber: return "Multicast Subscriber"
        case .others(let a, let b): return "Others(\(a), \(b))"
        }
    }
}

enum AccessPassStatus: UInt8, CaseIterable {
    case requested = 0
    case connected = 1
    case disconnected = 2
    case expired = 3

    var displayName: String {
        switch self {
        case .requested: return "Requested"
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .expired: return "Expired"
        }
    }
}

enum InterfaceStatus: UInt8, CaseIterable {
    case invalid = 0
    case unmanaged = 1
    case pending = 2
    case activated = 3
    case deleting = 4
    case rejected = 5
    case unlinked = 6

    var displayName: String {
        switch self {
        case .invalid: return "Invalid"
        case .unmanaged: return "Unmanaged"
        case .pending: return "Pending"
        case .activated: return "Activated"
        case .deleting: return "Deleting"
        case .rejected: return "Rejected"
        case .unlinked: return "Unlinked"
        }
    }
}

enum InterfaceType: UInt8, CaseIterable {
    case invalid = 0
    case loopback = 1
    case physical = 2

    var displayName: String {
        switch self {
        case .invalid: return "Invalid"
        case .loopback: return "Loopback"
        case .physical: return "Physical"
        }
    }
}

enum LoopbackType: UInt8, CaseIterable {
    case none = 0
    case vpnv4 = 1
    case ipv4 = 2
    case pimRpAddr = 3

    var displayName: String {
        switch self {
        case .none: return "None"
        case .vpnv4: return "VPNv4"
        case .ipv4: return "IPv4"
        case .pimRpAddr: return "PIM RP Address"
        }
    }
}

enum InterfaceCYOA: UInt8, CaseIterable {
    case none = 0
    case greOverDIA = 1
    case greOverFabric = 2
    case greOverPrivatePeering = 3
    case greOverPublicPeering = 4
    case greOverCable = 5

    var displayName: String {
        switch self {
        case .none: return "None"
        case .greOverDIA: return "GRE over DIA"
        case .greOverFabric: return "GRE over Fabric"
        case .greOverPrivatePeering: return "GRE over Private Peering"
        case .greOverPublicPeering: return "GRE over Public Peering"
        case .greOverCable: return "GRE over Cable"
        }
    }
}

enum InterfaceDIA: UInt8, CaseIterable {
    case none = 0
    case dia = 1

    var displayName: String {
        switch self {
        case .none: return "None"
        case .dia: return "DIA"
        }
    }
}

enum RoutingMode: UInt8, CaseIterable {
    case `static` = 0
    case bgp = 1

    var displayName: String {
        switch self {
        case .static: return "Static"
        case .bgp: return "BGP"
        }
    }
}
