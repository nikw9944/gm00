import XCTest
@testable import gm00

final class BorshDecoderTests: XCTestCase {

    func testReadU8() throws {
        let data = Data([42])
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readU8(), 42)
        XCTAssertEqual(decoder.remaining, 0)
    }

    func testReadBool() throws {
        let data = Data([0, 1, 255])
        let decoder = BorshDecoder(data: data)
        XCTAssertFalse(try decoder.readBool())
        XCTAssertTrue(try decoder.readBool())
        XCTAssertTrue(try decoder.readBool())
    }

    func testReadU16() throws {
        // 0x0102 little-endian = [0x02, 0x01] = 258
        let data = Data([0x02, 0x01])
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readU16(), 258)
    }

    func testReadU32() throws {
        // 1000 in LE = [0xe8, 0x03, 0x00, 0x00]
        let data = Data([0xe8, 0x03, 0x00, 0x00])
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readU32(), 1000)
    }

    func testReadU64() throws {
        // 1_000_000 in LE
        var value: UInt64 = 1_000_000
        let data = Data(bytes: &value, count: 8)
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readU64(), 1_000_000)
    }

    func testReadU128() throws {
        // low = 42, high = 0
        var low: UInt64 = 42
        var high: UInt64 = 0
        var data = Data(bytes: &low, count: 8)
        data.append(Data(bytes: &high, count: 8))
        let decoder = BorshDecoder(data: data)
        let result = try decoder.readU128()
        XCTAssertEqual(result.low, 42)
        XCTAssertEqual(result.high, 0)
    }

    func testReadF64() throws {
        var value: Double = 40.7128
        let data = Data(bytes: &value, count: 8)
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readF64(), 40.7128, accuracy: 0.0001)
    }

    func testReadString() throws {
        let str = "hello"
        let strBytes = Array(str.utf8)
        var length = UInt32(strBytes.count)
        var data = Data(bytes: &length, count: 4)
        data.append(Data(strBytes))
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readString(), "hello")
    }

    func testReadEmptyString() throws {
        var length: UInt32 = 0
        let data = Data(bytes: &length, count: 4)
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readString(), "")
    }

    func testReadPubkey() throws {
        // 32 zero bytes should encode to "1111...1" in Base58
        let data = Data(repeating: 0, count: 32)
        let decoder = BorshDecoder(data: data)
        let pubkey = try decoder.readPubkey()
        XCTAssertEqual(pubkey.count, 32) // All zeros encodes to 32 "1"s
        XCTAssertTrue(pubkey.allSatisfy { $0 == "1" })
    }

    func testReadIPv4() throws {
        let data = Data([10, 0, 1, 100])
        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readIPv4(), "10.0.1.100")
    }

    func testReadNetworkV4() throws {
        let data = Data([192, 168, 1, 0, 24])
        let decoder = BorshDecoder(data: data)
        let net = try decoder.readNetworkV4()
        XCTAssertEqual(net.ip, "192.168.1.0")
        XCTAssertEqual(net.prefixLength, 24)
        XCTAssertEqual(net.description, "192.168.1.0/24")
    }

    func testReadVecEmpty() throws {
        var count: UInt32 = 0
        let data = Data(bytes: &count, count: 4)
        let decoder = BorshDecoder(data: data)
        let result = try decoder.readVec { try decoder.readU8() }
        XCTAssertTrue(result.isEmpty)
    }

    func testReadVecU8() throws {
        var count: UInt32 = 3
        var data = Data(bytes: &count, count: 4)
        data.append(Data([10, 20, 30]))
        let decoder = BorshDecoder(data: data)
        let result = try decoder.readVec { try decoder.readU8() }
        XCTAssertEqual(result, [10, 20, 30])
    }

    func testReadOptionNone() throws {
        let data = Data([0])
        let decoder = BorshDecoder(data: data)
        let result = try decoder.readOption { try decoder.readU32() }
        XCTAssertNil(result)
    }

    func testReadOptionSome() throws {
        var value: UInt32 = 42
        var data = Data([1])
        data.append(Data(bytes: &value, count: 4))
        let decoder = BorshDecoder(data: data)
        let result = try decoder.readOption { try decoder.readU32() }
        XCTAssertEqual(result, 42)
    }

    func testInsufficientDataThrows() throws {
        let data = Data([1])
        let decoder = BorshDecoder(data: data)
        XCTAssertThrowsError(try decoder.readU32()) { error in
            guard case BorshDecoderError.insufficientData = error else {
                XCTFail("Expected insufficientData error")
                return
            }
        }
    }

    func testSequentialReads() throws {
        var data = Data()
        data.append(3) // u8
        var u16val: UInt16 = 500
        data.append(Data(bytes: &u16val, count: 2))
        var strLen: UInt32 = 3
        data.append(Data(bytes: &strLen, count: 4))
        data.append(Data("abc".utf8))
        data.append(Data([0])) // bool false

        let decoder = BorshDecoder(data: data)
        XCTAssertEqual(try decoder.readU8(), 3)
        XCTAssertEqual(try decoder.readU16(), 500)
        XCTAssertEqual(try decoder.readString(), "abc")
        XCTAssertFalse(try decoder.readBool())
        XCTAssertEqual(decoder.remaining, 0)
    }

    func testReadNetworkV4List() throws {
        var count: UInt32 = 2
        var data = Data(bytes: &count, count: 4)
        data.append(Data([10, 0, 0, 0, 8]))    // 10.0.0.0/8
        data.append(Data([172, 16, 0, 0, 12]))  // 172.16.0.0/12

        let decoder = BorshDecoder(data: data)
        let result = try decoder.readNetworkV4List()
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].description, "10.0.0.0/8")
        XCTAssertEqual(result[1].description, "172.16.0.0/12")
    }
}
