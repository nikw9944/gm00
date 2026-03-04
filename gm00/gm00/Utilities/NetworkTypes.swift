import Foundation

struct NetworkV4: Hashable, CustomStringConvertible {
    let ip: String
    let prefixLength: UInt8

    var description: String {
        "\(ip)/\(prefixLength)"
    }
}
