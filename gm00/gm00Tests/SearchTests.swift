import XCTest
@testable import gm00

final class SearchTests: XCTestCase {

    func testLocationSearchableText() {
        var loc = LocationAccount(
            accountType: AccountTypeDiscriminator.location,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            lat: 33.749, lng: -84.388, locId: 1,
            status: .activated, code: "ATL", name: "Atlanta",
            country: "US", referenceCount: 5
        )
        loc.pubkey = "SomePubkey123"

        XCTAssertTrue(loc.searchableText.lowercased().contains("atl"))
        XCTAssertTrue(loc.searchableText.lowercased().contains("atlanta"))
        XCTAssertTrue(loc.searchableText.lowercased().contains("us"))
        XCTAssertTrue(loc.searchableText.contains("SomePubkey123"))
    }

    func testExchangeSearchableText() {
        var ex = ExchangeAccount(
            accountType: AccountTypeDiscriminator.exchange,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            lat: 40.7128, lng: -74.006, bgpCommunity: 10100,
            unused: 0, status: .activated, code: "NYC",
            name: "New York", referenceCount: 3,
            device1Pk: "dev1", device2Pk: "dev2"
        )
        ex.pubkey = "ExPubkey456"

        XCTAssertTrue(ex.searchableText.contains("NYC"))
        XCTAssertTrue(ex.searchableText.contains("New York"))
    }

    func testDeviceSearchableText() {
        var dev = DeviceAccount(
            accountType: AccountTypeDiscriminator.device,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            locationPk: "loc", exchangePk: "ex",
            deviceType: .edge, publicIp: "10.0.1.1",
            status: .activated, code: "allnodes-fra1",
            dzPrefixes: [], metricsPublisherPk: "metrics",
            contributorPk: "contrib", mgmtVrf: "mgmt:vrf1",
            interfaces: [], referenceCount: 0,
            usersCount: 5, maxUsers: 100,
            deviceHealth: .readyForUsers, desiredStatus: .activated,
            unicastUsersCount: 3, multicastUsersCount: 2,
            maxUnicastUsers: 50, maxMulticastUsers: 50,
            reservedSeats: 0
        )
        dev.pubkey = "DevPubkey789"

        XCTAssertTrue(dev.searchableText.contains("allnodes-fra1"))
        XCTAssertTrue(dev.searchableText.contains("10.0.1.1"))
    }

    func testUserCompositeCodeSearch() {
        var user = DZUser(
            accountType: AccountTypeDiscriminator.user,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            userType: .ibrl, tenantPk: "tenant", devicePk: "device",
            cyoaType: .none, clientIp: "10.0.0.1", dzIp: "10.0.0.2",
            tunnelId: 507, tunnelNet: NetworkV4(ip: "10.0.0.0", prefixLength: 30),
            status: .activated, publishers: [], subscribers: [],
            validatorPubkey: "validator", tunnelEndpoint: "10.0.0.3"
        )
        user.pubkey = "UserPubkey"
        user.displayCode = "fra:allnodes-fra1:507"

        let searchText = user.searchableText.lowercased()
        XCTAssertTrue(searchText.contains("fra:allnodes-fra1:507"))
        XCTAssertTrue(searchText.contains("allnodes"))
        XCTAssertTrue(searchText.contains("10.0.0.1"))
    }

    func testUserWithoutDisplayCode() {
        var user = DZUser(
            accountType: AccountTypeDiscriminator.user,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            userType: .ibrl, tenantPk: "tenant", devicePk: "device",
            cyoaType: .none, clientIp: "10.0.0.1", dzIp: "10.0.0.2",
            tunnelId: 507, tunnelNet: NetworkV4(ip: "10.0.0.0", prefixLength: 30),
            status: .activated, publishers: [], subscribers: [],
            validatorPubkey: "validator", tunnelEndpoint: "10.0.0.3"
        )
        user.pubkey = "UserPubkey"

        // Without displayCode, should still search on IP and pubkey
        let searchText = user.searchableText.lowercased()
        XCTAssertTrue(searchText.contains("10.0.0.1"))
        XCTAssertTrue(searchText.contains("userpubkey"))
        XCTAssertFalse(searchText.contains("fra:")) // No display code set
    }

    func testAccessPassSearchableText() {
        var ap = AccessPassAccount(
            accountType: AccountTypeDiscriminator.accessPass,
            owner: "owner", bumpSeed: 0,
            accessPassType: .solanaValidator("validatorPk"),
            clientIp: "203.0.113.42", userPayer: "payer",
            lastAccessEpoch: 100, connectionCount: 5,
            status: .connected, mgroupPubAllowlist: [],
            mgroupSubAllowlist: [], flags: 0, tenantAllowlist: []
        )
        ap.pubkey = "APPubkey"

        XCTAssertTrue(ap.searchableText.contains("203.0.113.42"))
        XCTAssertTrue(ap.searchableText.contains("Solana Validator"))
    }

    func testAccountTypeInfoBrowsableTypes() {
        let types = AccountTypeInfo.browsableTypes
        XCTAssertEqual(types.count, 10)

        let names = types.map { $0.name }
        XCTAssertTrue(names.contains("Exchanges"))
        XCTAssertTrue(names.contains("Contributors"))
        XCTAssertTrue(names.contains("Locations"))
        XCTAssertTrue(names.contains("Devices"))
        XCTAssertTrue(names.contains("Links"))
        XCTAssertTrue(names.contains("Users"))
        XCTAssertTrue(names.contains("Multicast Groups"))
        XCTAssertTrue(names.contains("Tenants"))
        XCTAssertTrue(names.contains("Access Passes"))
        XCTAssertTrue(names.contains("Reservations"))
    }

    func testEnumDisplayNames() {
        XCTAssertEqual(LocationStatus.activated.displayName, "Activated")
        XCTAssertEqual(DeviceType.edge.displayName, "Edge")
        XCTAssertEqual(DeviceHealth.readyForUsers.displayName, "Ready for Users")
        XCTAssertEqual(LinkLinkType.wan.displayName, "WAN")
        XCTAssertEqual(UserType.ibrl.displayName, "IBRL")
        XCTAssertEqual(TenantPaymentStatus.paid.displayName, "Paid")
        XCTAssertEqual(AccessPassStatus.connected.displayName, "Connected")
        XCTAssertEqual(ContributorStatus.activated.displayName, "Activated")
        XCTAssertEqual(MulticastGroupStatus.pending.displayName, "Pending")
    }

    func testTruncatedPubkey() {
        let shortKey = "abc"
        XCTAssertEqual(shortKey.truncatedPubkey, "abc")

        let longKey = "GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah"
        XCTAssertEqual(longKey.truncatedPubkey, "GYhQDK...QVah")
    }

    func testBandwidthFormatting() {
        XCTAssertEqual(UInt64(1_000_000_000).formattedBandwidth, "1.0 Gbps")
        XCTAssertEqual(UInt64(100_000_000).formattedBandwidth, "100.0 Mbps")
        XCTAssertEqual(UInt64(10_000).formattedBandwidth, "10.0 Kbps")
        XCTAssertEqual(UInt64(500).formattedBandwidth, "500 bps")
    }

    func testDelayFormatting() {
        XCTAssertEqual(UInt64(5_000_000).formattedDelay, "5.00 ms")
        XCTAssertEqual(UInt64(1_500).formattedDelay, "1.50 µs")
        XCTAssertEqual(UInt64(100).formattedDelay, "100 ns")
    }
}
