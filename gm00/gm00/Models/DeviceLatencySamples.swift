import Foundation

struct DeviceLatencySamples: Identifiable, Hashable {
    let accountType: UInt8
    let epoch: UInt64
    let originDeviceAgentPk: String
    let originDevicePk: String
    let targetDevicePk: String
    let originDeviceLocationPk: String
    let targetDeviceLocationPk: String
    let linkPk: String
    let samplingIntervalMicroseconds: UInt64
    let startTimestampMicroseconds: UInt64
    let nextSampleIndex: UInt32
    let samples: [UInt32]

    var pubkey: String = ""
    var id: String { pubkey }

    static func == (lhs: DeviceLatencySamples, rhs: DeviceLatencySamples) -> Bool { lhs.pubkey == rhs.pubkey }
    func hash(into hasher: inout Hasher) { hasher.combine(pubkey) }
}

extension DeviceLatencySamples: BorshDecodable {
    static func decode(from decoder: BorshDecoder) throws -> DeviceLatencySamples {
        let accountType = try decoder.readU8()
        let epoch = try decoder.readU64()
        let originDeviceAgentPk = try decoder.readPubkey()
        let originDevicePk = try decoder.readPubkey()
        let targetDevicePk = try decoder.readPubkey()
        let originDeviceLocationPk = try decoder.readPubkey()
        let targetDeviceLocationPk = try decoder.readPubkey()
        let linkPk = try decoder.readPubkey()
        let samplingIntervalMicroseconds = try decoder.readU64()
        let startTimestampMicroseconds = try decoder.readU64()
        let nextSampleIndex = try decoder.readU32()
        try decoder.skip(128) // _unused

        let sampleCount = Int(nextSampleIndex)
        guard sampleCount <= 100_000 else { throw BorshDecoderError.overflow }
        var samples: [UInt32] = []
        samples.reserveCapacity(sampleCount)
        for _ in 0..<sampleCount {
            samples.append(try decoder.readU32())
        }

        return DeviceLatencySamples(
            accountType: accountType, epoch: epoch,
            originDeviceAgentPk: originDeviceAgentPk,
            originDevicePk: originDevicePk, targetDevicePk: targetDevicePk,
            originDeviceLocationPk: originDeviceLocationPk,
            targetDeviceLocationPk: targetDeviceLocationPk,
            linkPk: linkPk,
            samplingIntervalMicroseconds: samplingIntervalMicroseconds,
            startTimestampMicroseconds: startTimestampMicroseconds,
            nextSampleIndex: nextSampleIndex,
            samples: samples
        )
    }
}
