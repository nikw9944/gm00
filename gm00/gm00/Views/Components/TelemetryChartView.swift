import SwiftUI
import Charts

struct LossChartView: View {
    let data: [TelemetryDataPoint]

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value("Loss %", point.value)
            )
            .foregroundStyle(by: .value("Direction", point.series))
        }
        .chartYAxisLabel("Loss %")
        .chartYScale(domain: 0...max(maxY, 1))
        .chartForegroundStyleScale(seriesColors)
        .frame(height: 180)
    }

    private var maxY: Double {
        data.map(\.value).max() ?? 1
    }

    private var seriesColors: KeyValuePairs<String, Color> {
        let keys = Set(data.map(\.series)).sorted()
        if keys.count == 2 {
            return [keys[0]: .green, keys[1]: .blue]
        } else if keys.count == 1 {
            return [keys[0]: .green]
        }
        return ["": .gray]
    }
}

struct LatencyChartView: View {
    let data: [TelemetryDataPoint]

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value("RTT (ms)", point.value)
            )
            .foregroundStyle(by: .value("Series", point.series))
            .lineStyle(StrokeStyle(lineWidth: 2, dash: point.series.contains("P95") ? [5, 3] : []))
        }
        .chartYAxisLabel("ms")
        .chartForegroundStyleScale(seriesColors)
        .frame(height: 180)
    }

    private var seriesColors: KeyValuePairs<String, Color> {
        let keys = Set(data.map(\.series)).sorted()
        var pairs: [(String, Color)] = []
        for key in keys {
            if key.contains("A\u{2192}Z") {
                pairs.append((key, key.contains("P95") ? .green.opacity(0.6) : .green))
            } else if key.contains("Z\u{2192}A") {
                pairs.append((key, key.contains("P95") ? .blue.opacity(0.6) : .blue))
            } else {
                pairs.append((key, .gray))
            }
        }
        switch pairs.count {
        case 4: return [pairs[0].0: pairs[0].1, pairs[1].0: pairs[1].1, pairs[2].0: pairs[2].1, pairs[3].0: pairs[3].1]
        case 3: return [pairs[0].0: pairs[0].1, pairs[1].0: pairs[1].1, pairs[2].0: pairs[2].1]
        case 2: return [pairs[0].0: pairs[0].1, pairs[1].0: pairs[1].1]
        case 1: return [pairs[0].0: pairs[0].1]
        default: return ["": .gray]
        }
    }
}

struct JitterChartView: View {
    let data: [TelemetryDataPoint]

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value("Jitter (ms)", point.value)
            )
            .foregroundStyle(by: .value("Direction", point.series))
        }
        .chartYAxisLabel("ms")
        .chartForegroundStyleScale(seriesColors)
        .frame(height: 180)
    }

    private var seriesColors: KeyValuePairs<String, Color> {
        let keys = Set(data.map(\.series)).sorted()
        if keys.count == 2 {
            return [keys[0]: .green, keys[1]: .blue]
        } else if keys.count == 1 {
            return [keys[0]: .green]
        }
        return ["": .gray]
    }
}

struct TelemetryChartsSection: View {
    @ObservedObject var viewModel: LinkTelemetryViewModel
    var onRetry: (() -> Void)?

    var body: some View {
        if viewModel.isLoading {
            DetailSection(title: "Telemetry") {
                ProgressView("Loading telemetry data...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        } else if let error = viewModel.error {
            DetailSection(title: "Telemetry") {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let onRetry {
                        Button("Retry") { onRetry() }
                    }
                }
            }
        } else if viewModel.hasData {
            if !viewModel.lossData.isEmpty {
                DetailSection(title: "Packet Loss") {
                    LossChartView(data: viewModel.lossData)
                }
            }
            if !viewModel.rttData.isEmpty {
                DetailSection(title: "Round-Trip Time") {
                    LatencyChartView(data: viewModel.rttData)
                }
            }
            if !viewModel.jitterData.isEmpty {
                DetailSection(title: "Jitter (IPDV)") {
                    JitterChartView(data: viewModel.jitterData)
                }
            }
        }
    }
}
