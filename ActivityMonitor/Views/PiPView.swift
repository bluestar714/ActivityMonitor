//
//  PiPView.swift
//  ActivityMonitor
//
//  Picture-in-Picture style compact view for overlay display (iOS 17+ design)
//

import SwiftUI

@available(iOS 17.0, *)
struct PiPContainerView: View {
    @Binding var isPresented: Bool
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(SettingsManager.self) private var settingsManager

    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 100, y: 100)
    @State private var isDragging = false

    var body: some View {
        ZStack {
            // Ultra-thin material background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
                .sensoryFeedback(.impact, trigger: isPresented)

            // Compact metrics view
            CompactMetricsView()
                .position(position)
                .scaleEffect(isDragging ? 1.05 : 1.0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.7)) {
                                isDragging = true
                                position = value.location
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isDragging = false
                                snapToEdge()
                            }
                        }
                )
                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 12)
                .sensoryFeedback(.impact(weight: .medium), trigger: isDragging)
        }
    }

    private func snapToEdge() {
        let screenBounds = UIScreen.main.bounds
        let margin: CGFloat = 20

        // Snap to nearest vertical edge
        if position.x < screenBounds.width / 2 {
            position.x = margin + 110
        } else {
            position.x = screenBounds.width - margin - 110
        }

        // Keep within vertical bounds
        position.y = max(margin + 150, min(position.y, screenBounds.height - margin - 150))
    }
}

@available(iOS 17.0, *)
struct CompactMetricsView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
        VStack(spacing: 12) {
            // Header with enhanced gradient
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.pulse)

                Text("Activity Monitor")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Compact metric rows with iOS 17 styling
            VStack(spacing: 10) {
                if settingsManager.isMetricEnabled(.cpu) {
                    ModernCompactMetricRow(
                        icon: "cpu",
                        label: "CPU",
                        value: String(format: "%.0f%%", metricsManager.currentMetrics.cpu.usage),
                        color: .blue,
                        data: metricsManager.getHistory(for: .cpu)
                    )
                }

                if settingsManager.isMetricEnabled(.memory) {
                    ModernCompactMetricRow(
                        icon: "memorychip",
                        label: "RAM",
                        value: String(format: "%.0f%%", metricsManager.currentMetrics.memory.usagePercentage),
                        color: .green,
                        data: metricsManager.getHistory(for: .memory)
                    )
                }

                if settingsManager.isMetricEnabled(.network) {
                    ModernCompactMetricRow(
                        icon: "network",
                        label: "NET",
                        value: networkValue,
                        color: .orange,
                        data: metricsManager.networkHistory.map { $0.downloadSpeedMBps }
                    )
                }

                if settingsManager.isMetricEnabled(.storage) {
                    ModernCompactMetricRow(
                        icon: "internaldrive",
                        label: "SSD",
                        value: String(format: "%.0f%%", metricsManager.currentMetrics.storage.usagePercentage),
                        color: .purple,
                        data: metricsManager.getHistory(for: .storage)
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(width: 230)
        .background(backgroundView)
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(gradientOverlay)
            .overlay(borderOverlay)
    }

    private var gradientOverlay: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                .linearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        Color.white.opacity(0.06),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .strokeBorder(
                .linearGradient(
                    colors: [
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }

    private var networkValue: String {
        let speed = metricsManager.currentMetrics.network.downloadSpeedMBps
        if speed >= 1.0 {
            return String(format: "%.1f M", speed)
        } else {
            return String(format: "%.0f K", speed * 1024)
        }
    }
}

@available(iOS 17.0, *)
struct ModernCompactMetricRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let data: [Double]

    var body: some View {
        HStack(spacing: 11) {
            // Icon with enhanced gradient
            ZStack {
                Circle()
                    .fill(
                        .linearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color.gradient)
                    .symbolRenderingMode(.multicolor)
            }

            // Label
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .frame(width: 36, alignment: .leading)

            // Mini chart
            if data.count > 1 {
                CompactLineChartView(
                    data: data,
                    maxValue: 100,
                    color: color.opacity(0.9)
                )
                .frame(width: 68, height: 24)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 68, height: 24)
            }

            Spacer()

            // Value with gradient
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(
                    .linearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, alignment: .trailing)
                .contentTransition(.numericText())
                .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 1)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.09))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    PiPContainerView(isPresented: .constant(true))
        .environment(MetricsManager.shared)
        .environment(SettingsManager.shared)
}
