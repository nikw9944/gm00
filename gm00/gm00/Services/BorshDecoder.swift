import Foundation

enum BorshDecoderError: Error, LocalizedError {
    case insufficientData(expected: Int, available: Int)
    case invalidString
    case invalidEnumVariant(UInt8)
    case overflow

    var errorDescription: String? {
        switch self {
        case .insufficientData(let expected, let available):
            return "Borsh: need \(expected) bytes, have \(available)"
        case .invalidString:
            return "Borsh: invalid UTF-8 string"
        case .invalidEnumVariant(let v):
            return "Borsh: unknown enum variant \(v)"
        case .overflow:
            return "Borsh: numeric overflow"
        }
    }
}

class BorshDecoder {
    private let data: Data
    private(set) var cursor: Int = 0

    var remaining: Int { data.count - cursor }

    init(data: Data) {
        self.data = data
    }

    private func readBytes(_ count: Int) throws -> Data {
        guard cursor + count <= data.count else {
            throw BorshDecoderError.insufficientData(expected: count, available: remaining)
        }
        let result = data[cursor..<cursor + count]
        cursor += count
        return result
    }

    func readU8() throws -> UInt8 {
        let bytes = try readBytes(1)
        return bytes[bytes.startIndex]
    }

    func readBool() throws -> Bool {
        return try readU8() != 0
    }

    func readU16() throws -> UInt16 {
        let bytes = try readBytes(2)
        return bytes.withUnsafeBytes { $0.loadUnaligned(as: UInt16.self).littleEndian }
    }

    func readU32() throws -> UInt32 {
        let bytes = try readBytes(4)
        return bytes.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self).littleEndian }
    }

    func readU64() throws -> UInt64 {
        let bytes = try readBytes(8)
        return bytes.withUnsafeBytes { $0.loadUnaligned(as: UInt64.self).littleEndian }
    }

    func readU128() throws -> (high: UInt64, low: UInt64) {
        let low = try readU64()
        let high = try readU64()
        return (high, low)
    }

    func readI64() throws -> Int64 {
        let bytes = try readBytes(8)
        return bytes.withUnsafeBytes { $0.loadUnaligned(as: Int64.self).littleEndian }
    }

    func readF64() throws -> Double {
        let bytes = try readBytes(8)
        return bytes.withUnsafeBytes { $0.loadUnaligned(as: Double.self) }
    }

    func readString() throws -> String {
        let length = try readU32()
        guard length <= 10_000 else { throw BorshDecoderError.overflow }
        let bytes = try readBytes(Int(length))
        guard let str = String(data: bytes, encoding: .utf8) else {
            throw BorshDecoderError.invalidString
        }
        return str
    }

    func readPubkey() throws -> String {
        let bytes = try readBytes(32)
        return Base58.encode(bytes)
    }

    func readIPv4() throws -> String {
        let bytes = try readBytes(4)
        return "\(bytes[bytes.startIndex]).\(bytes[bytes.startIndex+1]).\(bytes[bytes.startIndex+2]).\(bytes[bytes.startIndex+3])"
    }

    func readNetworkV4() throws -> NetworkV4 {
        let ip = try readIPv4()
        let prefix = try readU8()
        return NetworkV4(ip: ip, prefixLength: prefix)
    }

    func readNetworkV4List() throws -> [NetworkV4] {
        let count = try readU32()
        guard count <= 10_000 else { throw BorshDecoderError.overflow }
        var result: [NetworkV4] = []
        result.reserveCapacity(Int(count))
        for _ in 0..<count {
            result.append(try readNetworkV4())
        }
        return result
    }

    func readOption<T>(_ reader: () throws -> T) throws -> T? {
        let tag = try readU8()
        if tag == 0 { return nil }
        return try reader()
    }

    func readVec<T>(_ reader: () throws -> T) throws -> [T] {
        let count = try readU32()
        guard count <= 100_000 else { throw BorshDecoderError.overflow }
        var result: [T] = []
        result.reserveCapacity(Int(count))
        for _ in 0..<count {
            result.append(try reader())
        }
        return result
    }

    func readPubkeyVec() throws -> [String] {
        try readVec { try self.readPubkey() }
    }

    func skip(_ count: Int) throws {
        _ = try readBytes(count)
    }
}

protocol BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> Self
}
