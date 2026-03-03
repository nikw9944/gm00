import Foundation

enum Base58 {
    private static let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    private static let baseCount = UInt(alphabet.count) // 58

    static func encode(_ bytes: Data) -> String {
        var bytes = Array(bytes)
        var zerosCount = 0
        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        var result: [Character] = []
        var temp = bytes
        while !temp.isEmpty {
            var carry: UInt = 0
            var newTemp: [UInt8] = []
            for byte in temp {
                carry = carry * 256 + UInt(byte)
                if !newTemp.isEmpty || carry >= baseCount {
                    newTemp.append(UInt8(carry / baseCount))
                    carry = carry % baseCount
                }
            }
            result.insert(alphabet[Int(carry)], at: 0)
            temp = newTemp
        }

        let prefix = String(repeating: alphabet[0], count: zerosCount)
        return prefix + String(result)
    }

    static func decode(_ string: String) -> Data? {
        var result: [UInt8] = []
        for char in string {
            guard let index = alphabet.firstIndex(of: char) else { return nil }
            var carry = index
            for j in stride(from: result.count - 1, through: 0, by: -1) {
                carry += Int(result[j]) * 58
                result[j] = UInt8(carry % 256)
                carry /= 256
            }
            while carry > 0 {
                result.insert(UInt8(carry % 256), at: 0)
                carry /= 256
            }
        }

        // Add leading zeros
        for char in string {
            if char != alphabet[0] { break }
            result.insert(0, at: 0)
        }

        return Data(result)
    }
}
