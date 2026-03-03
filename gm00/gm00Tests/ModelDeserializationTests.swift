import XCTest
@testable import gm00

final class ModelDeserializationTests: XCTestCase {

    // Helper to build a test Location account data
    private func buildLocationData(code: String = "ATL", name: String = "Atlanta", country: String = "US") -> Data {
        var data = Data()
        data.append(AccountTypeDiscriminator.location) // account_type
        data.append(Data(repeating: 1, count: 32)) // owner pubkey
        data.append(Data(repeating: 0, count: 16)) // index u128
        data.append(0) // bump_seed
        var lat: Double = 33.749
        data.append(Data(bytes: &lat, count: 8))
        var lng: Double = -84.388
        data.append(Data(bytes: &lng, count: 8))
        var locId: UInt32 = 1
        data.append(Data(bytes: &locId, count: 4))
        data.append(1) // status = Activated
        appendString(&data, code)
        appendString(&data, name)
        appendString(&data, country)
        var refCount: UInt32 = 5
        data.append(Data(bytes: &refCount, count: 4))
        return data
    }

    private func appendString(_ data: inout Data, _ str: String) {
        let bytes = Array(str.utf8)
        var len = UInt32(bytes.count)
        data.append(Data(bytes: &len, count: 4))
        data.append(Data(bytes))
    }

    func testDecodeLocation() throws {
        let data = buildLocationData()
        let decoder = BorshDecoder(data: data)
        let loc = try LocationAccount.decode(from: decoder)

        XCTAssertEqual(loc.accountType, AccountTypeDiscriminator.location)
        XCTAssertEqual(loc.code, "ATL")
        XCTAssertEqual(loc.name, "Atlanta")
        XCTAssertEqual(loc.country, "US")
        XCTAssertEqual(loc.lat, 33.749, accuracy: 0.001)
        XCTAssertEqual(loc.lng, -84.388, accuracy: 0.001)
        XCTAssertEqual(loc.status, .activated)
        XCTAssertEqual(loc.locId, 1)
        XCTAssertEqual(loc.referenceCount, 5)
    }

    private func buildExchangeData() -> Data {
        var data = Data()
        data.append(AccountTypeDiscriminator.exchange)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(Data(repeating: 0, count: 16)) // index
        data.append(0) // bump_seed
        var lat: Double = 40.7128
        data.append(Data(bytes: &lat, count: 8))
        var lng: Double = -74.006
        data.append(Data(bytes: &lng, count: 8))
        var bgp: UInt16 = 10100
        data.append(Data(bytes: &bgp, count: 2))
        var unused: UInt16 = 0
        data.append(Data(bytes: &unused, count: 2))
        data.append(1) // status = Activated
        appendString(&data, "NYC")
        appendString(&data, "New York")
        var refCount: UInt32 = 3
        data.append(Data(bytes: &refCount, count: 4))
        data.append(Data(repeating: 2, count: 32)) // device1_pk
        data.append(Data(repeating: 3, count: 32)) // device2_pk
        return data
    }

    func testDecodeExchange() throws {
        let data = buildExchangeData()
        let decoder = BorshDecoder(data: data)
        let ex = try ExchangeAccount.decode(from: decoder)

        XCTAssertEqual(ex.accountType, AccountTypeDiscriminator.exchange)
        XCTAssertEqual(ex.code, "NYC")
        XCTAssertEqual(ex.name, "New York")
        XCTAssertEqual(ex.bgpCommunity, 10100)
        XCTAssertEqual(ex.status, .activated)
        XCTAssertEqual(ex.referenceCount, 3)
    }

    private func buildContributorData() -> Data {
        var data = Data()
        data.append(AccountTypeDiscriminator.contributor)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(Data(repeating: 0, count: 16)) // index
        data.append(0) // bump_seed
        data.append(1) // status = Activated
        appendString(&data, "malbec")
        var refCount: UInt32 = 10
        data.append(Data(bytes: &refCount, count: 4))
        data.append(Data(repeating: 4, count: 32)) // ops_manager_pk
        return data
    }

    func testDecodeContributor() throws {
        let data = buildContributorData()
        let decoder = BorshDecoder(data: data)
        let contrib = try ContributorAccount.decode(from: decoder)

        XCTAssertEqual(contrib.code, "malbec")
        XCTAssertEqual(contrib.status, .activated)
        XCTAssertEqual(contrib.referenceCount, 10)
    }

    private func buildReservationData() -> Data {
        var data = Data()
        data.append(AccountTypeDiscriminator.reservation)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(0) // bump_seed
        data.append(Data(repeating: 5, count: 32)) // device_pk
        data.append(Data([10, 0, 1, 50])) // client_ip
        return data
    }

    func testDecodeReservation() throws {
        let data = buildReservationData()
        let decoder = BorshDecoder(data: data)
        let res = try ReservationAccount.decode(from: decoder)

        XCTAssertEqual(res.accountType, AccountTypeDiscriminator.reservation)
        XCTAssertEqual(res.clientIp, "10.0.1.50")
    }

    func testDecodeMulticastGroup() throws {
        var data = Data()
        data.append(AccountTypeDiscriminator.multicastGroup)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(Data(repeating: 0, count: 16)) // index
        data.append(0) // bump_seed
        data.append(Data(repeating: 2, count: 32)) // tenant_pk
        data.append(Data([239, 1, 1, 1])) // multicast_ip 239.1.1.1
        var bw: UInt64 = 1_000_000_000
        data.append(Data(bytes: &bw, count: 8))
        data.append(1) // status = Activated
        appendString(&data, "mcast-test")
        var pubCount: UInt32 = 2
        data.append(Data(bytes: &pubCount, count: 4))
        var subCount: UInt32 = 10
        data.append(Data(bytes: &subCount, count: 4))

        let decoder = BorshDecoder(data: data)
        let mg = try MulticastGroupAccount.decode(from: decoder)

        XCTAssertEqual(mg.code, "mcast-test")
        XCTAssertEqual(mg.multicastIp, "239.1.1.1")
        XCTAssertEqual(mg.maxBandwidth, 1_000_000_000)
        XCTAssertEqual(mg.publisherCount, 2)
        XCTAssertEqual(mg.subscriberCount, 10)
    }

    func testSearchableTextLocation() {
        var loc = try! LocationAccount.decode(from: BorshDecoder(data: buildLocationData()))
        loc.pubkey = "TestPubkey123"
        XCTAssertTrue(loc.searchableText.contains("ATL"))
        XCTAssertTrue(loc.searchableText.contains("Atlanta"))
        XCTAssertTrue(loc.searchableText.contains("US"))
        XCTAssertTrue(loc.searchableText.contains("TestPubkey123"))
    }

    func testUserDisplayCode() {
        var user = DZUser(
            accountType: AccountTypeDiscriminator.user,
            owner: "owner", index: (high: 0, low: 0), bumpSeed: 0,
            userType: .ibrl, tenantPk: "tenant", devicePk: "device",
            cyoaType: .none, clientIp: "10.0.0.1", dzIp: "10.0.0.2",
            tunnelId: 507, tunnelNet: NetworkV4(ip: "10.0.0.0", prefixLength: 30),
            status: .activated, publishers: [], subscribers: [],
            validatorPubkey: "validator", tunnelEndpoint: "10.0.0.3"
        )

        XCTAssertNil(user.displayCode)
        XCTAssertEqual(user.sortKey, "") // pubkey is empty string

        user.displayCode = "fra:allnodes-fra1:507"
        XCTAssertEqual(user.sortKey, "fra:allnodes-fra1:507")
        XCTAssertTrue(user.searchableText.contains("fra:allnodes-fra1:507"))
    }
}
