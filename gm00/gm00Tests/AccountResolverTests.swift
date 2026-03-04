import XCTest
@testable import gm00

final class AccountResolverTests: XCTestCase {

    func testResolveLocationFromData() throws {
        var data = Data()
        data.append(AccountTypeDiscriminator.location)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(Data(repeating: 0, count: 16)) // index
        data.append(0) // bump_seed
        var lat: Double = 0.0
        data.append(Data(bytes: &lat, count: 8))
        var lng: Double = 0.0
        data.append(Data(bytes: &lng, count: 8))
        var locId: UInt32 = 0
        data.append(Data(bytes: &locId, count: 4))
        data.append(0) // status
        appendString(&data, "TST")
        appendString(&data, "Test")
        appendString(&data, "US")
        var refCount: UInt32 = 0
        data.append(Data(bytes: &refCount, count: 4))

        let resolver = AccountResolver(rpcClient: SolanaRPCClient(cluster: .devnet))
        let result = try resolver.resolveFromData(pubkey: "TestPubkey", data: data)

        if case .location(let pk, let loc) = result {
            XCTAssertEqual(pk, "TestPubkey")
            XCTAssertEqual(loc.code, "TST")
        } else {
            XCTFail("Expected location account")
        }
    }

    func testResolveReservationFromData() throws {
        var data = Data()
        data.append(AccountTypeDiscriminator.reservation)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(0) // bump_seed
        data.append(Data(repeating: 5, count: 32)) // device_pk
        data.append(Data([192, 168, 1, 1])) // client_ip

        let resolver = AccountResolver(rpcClient: SolanaRPCClient(cluster: .devnet))
        let result = try resolver.resolveFromData(pubkey: "ResPubkey", data: data)

        if case .reservation(let pk, let res) = result {
            XCTAssertEqual(pk, "ResPubkey")
            XCTAssertEqual(res.clientIp, "192.168.1.1")
        } else {
            XCTFail("Expected reservation account")
        }
    }

    func testResolveUnknownDiscriminator() throws {
        let data = Data([255, 0, 0, 0]) // Unknown discriminator
        let resolver = AccountResolver(rpcClient: SolanaRPCClient(cluster: .devnet))

        XCTAssertThrowsError(try resolver.resolveFromData(pubkey: "Unknown", data: data))
    }

    func testResolveEmptyData() throws {
        let data = Data()
        let resolver = AccountResolver(rpcClient: SolanaRPCClient(cluster: .devnet))

        XCTAssertThrowsError(try resolver.resolveFromData(pubkey: "Empty", data: data))
    }

    func testResolvedAccountTypeName() throws {
        var data = Data()
        data.append(AccountTypeDiscriminator.contributor)
        data.append(Data(repeating: 1, count: 32)) // owner
        data.append(Data(repeating: 0, count: 16)) // index
        data.append(0) // bump_seed
        data.append(1) // status
        appendString(&data, "test")
        var refCount: UInt32 = 0
        data.append(Data(bytes: &refCount, count: 4))
        data.append(Data(repeating: 4, count: 32)) // ops_manager_pk

        let resolver = AccountResolver(rpcClient: SolanaRPCClient(cluster: .devnet))
        let result = try resolver.resolveFromData(pubkey: "ContribPK", data: data)

        XCTAssertEqual(result.typeName, "Contributor")
        XCTAssertEqual(result.pubkey, "ContribPK")
    }

    private func appendString(_ data: inout Data, _ str: String) {
        let bytes = Array(str.utf8)
        var len = UInt32(bytes.count)
        data.append(Data(bytes: &len, count: 4))
        data.append(Data(bytes))
    }
}
