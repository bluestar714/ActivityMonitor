//
//  ModernMetricCardView.swift
//  PerfScopeX
//
//  iOS 17+ design metric display card with latest visual effects
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct ModernMetricCardView<TrailingButton: View>: View {
    let type: MetricType
    let currentValue: String
    let subtitle: String
    let data: [Double]
    let maxValue: Double
    let color: Color
    let trailingButton: TrailingButton?

    @State private var animateGradient = false
    @State private var isPressed = false

    init(
        type: MetricType,
        currentValue: String,
        subtitle: String,
        data: [Double],
        maxValue: Double,
        color: Color,
        @ViewBuilder trailingButton: () -> TrailingButton
    ) {
        self.type = type
        self.currentValue = currentValue
        self.subtitle = subtitle
        self.data = data
        self.maxValue = maxValue
        self.color = color
        self.trailingButton = trailingButton()
    }

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
                    HStack(spacing: 4) {
                        Text(type.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        if let button = trailingButton {
                            button
                        }
                    }

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
            liquidGlassBackground
        }
        .overlay {
            glossyHighlight
        }
        .overlay {
            liquidBorder
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.smooth(duration: 0.4, extraBounce: 0.1), value: isPressed)
    }

    private var liquidGlassBackground: some View {
        ZStack {
            // Base glass layer with gradient
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    .linearGradient(
                        colors: [
                            color.opacity(0.08),
                            color.opacity(0.03),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Glass material overlay
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.9)

            // Inner glow effect
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    .radialGradient(
                        colors: [
                            color.opacity(0.12),
                            color.opacity(0.05),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .blendMode(.plusLighter)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: color.opacity(isPressed ? 0.25 : 0.15), radius: isPressed ? 12 : 20, x: 0, y: isPressed ? 6 : 10)
    }

    private var glossyHighlight: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                .linearGradient(
                    colors: [
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .frame(height: 1)
            .offset(y: -23)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var liquidBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(
                .angularGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.3),
                        color.opacity(0.1),
                        .white.opacity(0.2),
                        color.opacity(0.1),
                        color.opacity(0.3),
                        color.opacity(0.6)
                    ],
                    center: .topLeading,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 2
            )
            .blur(radius: 0.5)
            .opacity(0.8)
    }
}

// MARK: - Convenience Initializer (No Trailing Button)

@available(iOS 17.0, *)
extension ModernMetricCardView where TrailingButton == EmptyView {
    init(
        type: MetricType,
        currentValue: String,
        subtitle: String,
        data: [Double],
        maxValue: Double,
        color: Color
    ) {
        self.type = type
        self.currentValue = currentValue
        self.subtitle = subtitle
        self.data = data
        self.maxValue = maxValue
        self.color = color
        self.trailingButton = nil
    }
}

// MARK: - Dual Metric Card (For Read/Write metrics like Disk I/O)

@available(iOS 17.0, *)
struct DualMetricCardView: View {
    let type: MetricType
    let currentValue1: String
    let currentValue2: String
    let subtitle: String
    let data1: [Double]
    let data2: [Double]
    let maxValue: Double
    let color1: Color
    let color2: Color
    let label1: String
    let label2: String

    @State private var animateGradient = false
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with icon and dual values
            HStack(alignment: .top, spacing: 12) {
                // Icon with animated gradient background
                ZStack {
                    Circle()
                        .fill(
                            .linearGradient(
                                colors: [
                                    color1.opacity(0.25),
                                    color1.opacity(0.1)
                                ],
                                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                endPoint: animateGradient ? .bottomTrailing : .topLeading
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: color1.opacity(0.2), radius: 8, x: 0, y: 4)

                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color1.gradient)
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

                // Dual values stacked
                VStack(alignment: .trailing, spacing: 4) {
                    // First value
                    HStack(spacing: 6) {
                        Text(label1)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(color1)
                        Text(currentValue1)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [color1, color1.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .contentTransition(.numericText())
                    }

                    // Second value
                    HStack(spacing: 6) {
                        Text(label2)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(color2)
                        Text(currentValue2)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [color2, color2.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .contentTransition(.numericText())
                    }
                }
            }

            // Dual line chart
            DualLineChartView(
                data1: data1,
                data2: data2,
                maxValue: maxValue,
                color1: color1,
                color2: color2,
                label1: label1,
                label2: label2
            )
            .frame(height: 90)
        }
        .padding(18)
        .background {
            dualLiquidGlassBackground
        }
        .overlay {
            dualGlossyHighlight
        }
        .overlay {
            dualLiquidBorder
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.smooth(duration: 0.4, extraBounce: 0.1), value: isPressed)
    }

    private var dualLiquidGlassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    .linearGradient(
                        colors: [
                            color1.opacity(0.08),
                            color1.opacity(0.03),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.9)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    .radialGradient(
                        colors: [
                            color1.opacity(0.12),
                            color1.opacity(0.05),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .blendMode(.plusLighter)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: color1.opacity(isPressed ? 0.25 : 0.15), radius: isPressed ? 12 : 20, x: 0, y: isPressed ? 6 : 10)
    }

    private var dualGlossyHighlight: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                .linearGradient(
                    colors: [
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .frame(height: 1)
            .offset(y: -23)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var dualLiquidBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(
                .angularGradient(
                    colors: [
                        color1.opacity(0.6),
                        color1.opacity(0.3),
                        color1.opacity(0.1),
                        .white.opacity(0.2),
                        color1.opacity(0.1),
                        color1.opacity(0.3),
                        color1.opacity(0.6)
                    ],
                    center: .topLeading,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 2
            )
            .blur(radius: 0.5)
            .opacity(0.8)
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
            compactGlassBackground
        }
        .overlay {
            compactBorder
        }
    }

    private var compactGlassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    .linearGradient(
                        colors: [
                            color.opacity(0.06),
                            color.opacity(0.02),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .opacity(0.85)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    .radialGradient(
                        colors: [
                            color.opacity(0.08),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .blendMode(.plusLighter)
        }
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .shadow(color: color.opacity(0.12), radius: 12, x: 0, y: 6)
    }

    private var compactBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
                .linearGradient(
                    colors: [
                        color.opacity(0.5),
                        .white.opacity(0.15),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            .opacity(0.7)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 16) {
        ModernMetricCardView(
            type: .cpuTotal,
            currentValue: "45%",
            subtitle: "User: 30% • System: 15%",
            data: [20, 35, 45, 30, 55, 70, 45, 60, 40, 50],
            maxValue: 100,
            color: .blue
        )

        CompactModernMetricCardView(
            type: .memoryTotal,
            currentValue: "3.2 GB",
            data: [40, 42, 45, 48, 50, 52, 55],
            maxValue: 100,
            color: .green
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
