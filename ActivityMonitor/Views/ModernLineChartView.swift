//
//  ModernLineChartView.swift
//  ActivityMonitor
//
//  iOS 17+ Swift Charts implementation for performance metrics
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct ModernLineChartView: View {
    let data: [Double]
    let maxValue: Double
    let color: Color
    let label: String

    init(data: [Double], maxValue: Double = 100.0, color: Color = .blue, label: String = "") {
        self.data = data
        self.maxValue = maxValue
        self.color = color
        self.label = label
    }

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color.gradient)
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)

                AreaMark(
                    x: .value("Time", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.1),
                            color.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(.secondary.opacity(0.2))
                AxisValueLabel()
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .chartYScale(domain: 0...maxValue)
        .chartPlotStyle { plotArea in
            plotArea
                .background(.clear)
        }
    }
}

// MARK: - Compact Chart (No Axes)

@available(iOS 17.0, *)
struct CompactLineChartView: View {
    let data: [Double]
    let maxValue: Double
    let color: Color

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...maxValue)
        .chartPlotStyle { plotArea in
            plotArea.background(.clear)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 20) {
        ModernLineChartView(
            data: [20, 35, 45, 30, 55, 70, 45, 60, 40, 50, 65, 55],
            maxValue: 100,
            color: .blue,
            label: "CPU"
        )
        .frame(height: 120)
        .padding()

        CompactLineChartView(
            data: [40, 42, 45, 48, 50, 52, 55, 53, 58],
            maxValue: 100,
            color: .green
        )
        .frame(height: 60)
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
