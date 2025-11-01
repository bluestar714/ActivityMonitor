//
//  MetricCardView.swift
//  ActivityMonitor
//
//  Compact metric display card with real-time chart
//

import SwiftUI

struct MetricCardView: View {
    let type: MetricType
    let currentValue: String
    let subtitle: String
    let data: [Double]
    let maxValue: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)

                Text(type.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text(currentValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }

            // Subtitle
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // Chart
            LineChartView(
                data: data,
                maxValue: maxValue,
                color: color,
                showGradient: true
            )
            .frame(height: 60)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Compact Metric Card

struct CompactMetricCardView: View {
    let type: MetricType
    let currentValue: String
    let data: [Double]
    let maxValue: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon and value
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: type.icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)

                    Text(type.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Text(currentValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }

            Spacer()

            // Mini chart
            LineChartView(
                data: data,
                maxValue: maxValue,
                color: color,
                showGradient: false
            )
            .frame(width: 80, height: 40)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

struct MetricCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MetricCardView(
                type: .cpu,
                currentValue: "45%",
                subtitle: "8 cores active",
                data: [20, 35, 45, 30, 55, 70, 45, 60, 40, 50],
                maxValue: 100,
                color: .blue
            )

            CompactMetricCardView(
                type: .memory,
                currentValue: "3.2 GB",
                data: [40, 42, 45, 48, 50, 52, 55],
                maxValue: 100,
                color: .green
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
