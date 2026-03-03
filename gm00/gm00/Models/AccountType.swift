import Foundation

enum AccountTypeDiscriminator {
    static let none: UInt8 = 0
    static let globalState: UInt8 = 1
    static let globalConfig: UInt8 = 2
    static let location: UInt8 = 3
    static let exchange: UInt8 = 4
    static let device: UInt8 = 5
    static let link: UInt8 = 6
    static let user: UInt8 = 7
    static let multicastGroup: UInt8 = 8
    static let programConfig: UInt8 = 9
    static let contributor: UInt8 = 10
    static let accessPass: UInt8 = 11
    static let resourceExtension: UInt8 = 12
    static let tenant: UInt8 = 13
    static let reservation: UInt8 = 14
}

struct AccountTypeInfo: Hashable, Identifiable {
    let id: UInt8
    let name: String
    let icon: String
    let description: String

    static let browsableTypes: [AccountTypeInfo] = [
        AccountTypeInfo(id: AccountTypeDiscriminator.exchange, name: "Exchanges", icon: "building.2", description: "Network exchange points"),
        AccountTypeInfo(id: AccountTypeDiscriminator.contributor, name: "Contributors", icon: "person.3", description: "Network contributors"),
        AccountTypeInfo(id: AccountTypeDiscriminator.location, name: "Locations", icon: "mappin.and.ellipse", description: "Physical locations"),
        AccountTypeInfo(id: AccountTypeDiscriminator.device, name: "Devices", icon: "server.rack", description: "Network devices"),
        AccountTypeInfo(id: AccountTypeDiscriminator.link, name: "Links", icon: "link", description: "Network links"),
        AccountTypeInfo(id: AccountTypeDiscriminator.user, name: "Users", icon: "person.crop.circle", description: "Network users"),
        AccountTypeInfo(id: AccountTypeDiscriminator.multicastGroup, name: "Multicast Groups", icon: "antenna.radiowaves.left.and.right", description: "Multicast groups"),
        AccountTypeInfo(id: AccountTypeDiscriminator.tenant, name: "Tenants", icon: "building", description: "Service tenants"),
        AccountTypeInfo(id: AccountTypeDiscriminator.accessPass, name: "Access Passes", icon: "key", description: "Access passes"),
        AccountTypeInfo(id: AccountTypeDiscriminator.reservation, name: "Reservations", icon: "calendar.badge.clock", description: "Device reservations"),
    ]
}
