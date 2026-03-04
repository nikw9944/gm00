import Foundation

extension String {
    var truncatedPubkey: String {
        guard count > 12 else { return self }
        return "\(prefix(6))...\(suffix(4))"
    }

    func formatBandwidth(_ bps: UInt64) -> String {
        if bps >= 1_000_000_000 {
            return String(format: "%.1f Gbps", Double(bps) / 1_000_000_000)
        } else if bps >= 1_000_000 {
            return String(format: "%.1f Mbps", Double(bps) / 1_000_000)
        } else if bps >= 1_000 {
            return String(format: "%.1f Kbps", Double(bps) / 1_000)
        }
        return "\(bps) bps"
    }
}

extension UInt64 {
    var formattedBandwidth: String {
        if self >= 1_000_000_000 {
            return String(format: "%.1f Gbps", Double(self) / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.1f Mbps", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1f Kbps", Double(self) / 1_000)
        }
        return "\(self) bps"
    }

    var formattedDelay: String {
        if self >= 1_000_000 {
            return String(format: "%.2f ms", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.2f µs", Double(self) / 1_000)
        }
        return "\(self) ns"
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
