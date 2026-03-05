import Foundation

struct TelemetryDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let series: String
}

@MainActor
class LinkTelemetryViewModel: ObservableObject {
    @Published var lossData: [TelemetryDataPoint] = []
    @Published var rttData: [TelemetryDataPoint] = []
    @Published var jitterData: [TelemetryDataPoint] = []
    @Published var isLoading = false
    @Published var error: String?

    private let bucketSeconds: TimeInterval = 300 // 5-minute buckets

    var hasData: Bool {
        !lossData.isEmpty || !rttData.isEmpty || !jitterData.isEmpty
    }

    func loadTelemetry(linkPk: String, sideAPk: String, sideZPk: String, rpcClient: SolanaRPCClient, cluster: SolanaCluster) async {
        isLoading = true
        error = nil

        do {
            let telemetryProgramId = cluster.telemetryProgramId
            let linkPkBytes = Base58.decode(linkPk)
            guard let linkPkBytes else {
                error = "Invalid link pubkey"
                isLoading = false
                return
            }

            let filters: [[String: Any]] = [
                ["memcmp": ["offset": 0, "bytes": Base58.encode(Data([TelemetryAccountTypeDiscriminator.deviceLatencySamples]))] as [String: Any]],
                ["memcmp": ["offset": 169, "bytes": Base58.encode(linkPkBytes)] as [String: Any]]
            ]

            let accounts = try await rpcClient.getProgramAccounts(programId: telemetryProgramId, filters: filters)

            var allSamples: [DeviceLatencySamples] = []
            for (pubkey, data) in accounts {
                let decoder = BorshDecoder(data: data)
                var sample = try DeviceLatencySamples.decode(from: decoder)
                sample.pubkey = pubkey
                allSamples.append(sample)
            }

            processSamples(allSamples, sideAPk: sideAPk, sideZPk: sideZPk)
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    private func processSamples(_ allSamples: [DeviceLatencySamples], sideAPk: String, sideZPk: String) {
        var loss: [TelemetryDataPoint] = []
        var rtt: [TelemetryDataPoint] = []
        var jitter: [TelemetryDataPoint] = []

        for sample in allSamples {
            let direction: String
            if sample.originDevicePk == sideAPk {
                direction = "A\u{2192}Z"
            } else if sample.originDevicePk == sideZPk {
                direction = "Z\u{2192}A"
            } else {
                direction = "Unknown"
            }

            let intervalUs = Double(sample.samplingIntervalMicroseconds)
            let startUs = Double(sample.startTimestampMicroseconds)
            let bucketUs = bucketSeconds * 1_000_000

            guard intervalUs > 0, sample.samples.count > 0 else { continue }

            // Group samples into time buckets
            var buckets: [Int64: [UInt32]] = [:]
            for (i, val) in sample.samples.enumerated() {
                let timeUs = startUs + Double(i) * intervalUs
                let bucketKey = Int64(timeUs / bucketUs)
                buckets[bucketKey, default: []].append(val)
            }

            for (bucketKey, values) in buckets.sorted(by: { $0.key < $1.key }) {
                let bucketDate = Date(timeIntervalSince1970: Double(bucketKey) * bucketSeconds)

                // Loss: percentage of zero samples
                let totalCount = values.count
                let lossCount = values.filter { $0 == 0 }.count
                let lossPercent = Double(lossCount) / Double(totalCount) * 100.0
                loss.append(TelemetryDataPoint(date: bucketDate, value: lossPercent, series: direction))

                // RTT: average of non-zero samples (convert microseconds to milliseconds)
                let nonZero = values.filter { $0 > 0 }
                if !nonZero.isEmpty {
                    let avgRtt = nonZero.map { Double($0) / 1000.0 }.reduce(0, +) / Double(nonZero.count)
                    rtt.append(TelemetryDataPoint(date: bucketDate, value: avgRtt, series: "\(direction) avg"))

                    let sorted = nonZero.sorted()
                    let p95Index = Int(Double(sorted.count) * 0.95)
                    let p95Rtt = Double(sorted[min(p95Index, sorted.count - 1)]) / 1000.0
                    rtt.append(TelemetryDataPoint(date: bucketDate, value: p95Rtt, series: "\(direction) P95"))
                }

                // Jitter (IPDV): average absolute difference between consecutive non-zero samples
                if nonZero.count > 1 {
                    var jitterSum: Double = 0
                    var jitterCount = 0
                    for i in 1..<nonZero.count {
                        jitterSum += abs(Double(nonZero[i]) - Double(nonZero[i - 1])) / 1000.0
                        jitterCount += 1
                    }
                    if jitterCount > 0 {
                        jitter.append(TelemetryDataPoint(date: bucketDate, value: jitterSum / Double(jitterCount), series: direction))
                    }
                }
            }
        }

        self.lossData = loss.sorted { $0.date < $1.date }
        self.rttData = rtt.sorted { $0.date < $1.date }
        self.jitterData = jitter.sorted { $0.date < $1.date }
    }
}
