//
//  ModernMetricCardView.swift
//  ActivityMonitor
//
//  iOS 17+ design metric display card with latest visual effects
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct ModernMetricCardView: View {
    let type: MetricType
    let currentValue: String
    let subtitle: String
    let data: [Double]
    let maxValue: Double
    let color: Color

    @State private var animateGradient = false
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with icon and value
            HStack(alignment: .top, spacing: 12) {
                // Icon with animated gradient background
                ZStack {
                    Circle()
                        .fill(
                            .linearGradient(
                                colors: [
                                    color.opacity(0.25),
                                    color.opacity(0.1)
                                ],
                                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                endPoint: animateGradient ? .bottomTrailing : .topLeading
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)

                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color.gradient)
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.bounce, value: animateGradient)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Current value with mesh gradient
                Text(currentValue)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            // Chart with iOS 17 enhancements
            ModernLineChartView(
                data: data,
                maxValue: maxValue,
                color: color,
                label: type.rawValue
            )
            .frame(height: 90)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: color.opacity(isPressed ? 0.2 : 0.1), radius: isPressed ? 8 : 12, x: 0, y: isPressed ? 4 : 6)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    .linearGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Compact Modern Metric Card

@available(iOS 17.0, *)
struct CompactModernMetricCardView: View {
    let type: MetricType
    let currentValue: String
    let data: [Double]
    let maxValue: Double
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color.gradient)
                .symbolRenderingMode(.multicolor)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(color.opacity(0.15))
                        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
                }

            // Label and value
            VStack(alignment: .leading, spacing: 3) {
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(currentValue)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(color.gradient)
                    .contentTransition(.numericText())
            }

            Spacer()

            // Mini chart
            if data.count > 1 {
                CompactLineChartView(
                    data: data,
                    maxValue: maxValue,
                    color: color
                )
                .frame(width: 75, height: 38)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 16) {
        ModernMetricCardView(
            type: .cpu,
            currentValue: "45%",
            subtitle: "User: 30% • System: 15%",
            data: [20, 35, 45, 30, 55, 70, 45, 60, 40, 50],
            maxValue: 100,
            color: .blue
        )

        CompactModernMetricCardView(
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
