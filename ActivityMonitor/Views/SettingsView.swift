//
//  SettingsView.swift
//  ActivityMonitor
//
//  Settings screen for customizing metrics and preferences (iOS 17+ design)
//

import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section {
                    @Bindable var settings = settingsManager

                    // Custom segmented control with icons
                    HStack(spacing: 0) {
                        // Light Theme Button
                        Button {
                            settings.settings.appTheme = .light
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 14))
                                Text("Light")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(settings.settings.appTheme == .light ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(settings.settings.appTheme == .light ? Color.accentColor : Color.clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .frame(height: 30)

                        // Dark Theme Button
                        Button {
                            settings.settings.appTheme = .dark
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                Text("Dark")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(settings.settings.appTheme == .dark ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(settings.settings.appTheme == .dark ? Color.accentColor : Color.clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.appTheme) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                } header: {
                    Text("Appearance")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Choose the color theme for the entire app including Picture-in-Picture mode.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Enabled Metrics Section
                Section {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        @Bindable var settings = settingsManager

                        Toggle(isOn: Binding(
                            get: { settingsManager.isMetricEnabled(metric) },
                            set: { _ in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    settingsManager.toggleMetric(metric)
                                }
                                metricsManager.startMonitoring()
                            }
                        )) {
                            Label {
                                Text(metric.rawValue)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            } icon: {
                                Image(systemName: metric.icon)
                                    .foregroundStyle(colorForMetric(metric).gradient)
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 20))
                                    .symbolEffect(.bounce, value: settingsManager.isMetricEnabled(metric))
                            }
                        }
                        .tint(colorForMetric(metric))
                        .sensoryFeedback(.selection, trigger: settingsManager.isMetricEnabled(metric)) { _, _ in
                            settingsManager.settings.hapticsEnabled
                        }
                    }
                } header: {
                    Text("Enabled Metrics")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Toggle metrics on or off to customize your dashboard.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Performance Section
                Section {
                    @Bindable var settings = settingsManager

                    Picker("Update Interval", selection: $settings.settings.refreshInterval) {
                        Text("0.5 seconds").tag(0.5)
                        Text("1 second").tag(1.0)
                        Text("2 seconds").tag(2.0)
                        Text("5 seconds").tag(5.0)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settingsManager.settings.refreshInterval) { _, _ in
                        metricsManager.startMonitoring()
                    }

                    Picker("Chart Data Points", selection: $settings.settings.maxDataPoints) {
                        Text("50 points").tag(50)
                        Text("100 points").tag(100)
                        Text("200 points").tag(200)
                        Text("300 points").tag(300)
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Performance")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Lower intervals and more data points use more resources but provide more detailed monitoring.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Display Section
                Section {
                    @Bindable var settings = settingsManager

                    Toggle(isOn: $settings.settings.showDetailedCPU) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detailed CPU View")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                Text("Show User/System separately")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "cpu")
                                .foregroundStyle(.blue.gradient)
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 20))
                                .symbolEffect(.pulse, value: settings.settings.showDetailedCPU)
                        }
                    }
                    .tint(.blue)
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedCPU) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                } header: {
                    Text("Display Options")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("When enabled, CPU metric shows User and System usage separately. Tap the CPU card to quickly toggle this setting.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Haptic Feedback Section
                Section {
                    @Bindable var settings = settingsManager

                    Toggle(isOn: $settings.settings.hapticsEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Haptic Feedback")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                Text("Vibrate on interactions")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: settings.settings.hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .foregroundStyle(.purple.gradient)
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 20))
                                .symbolEffect(.bounce, value: settings.settings.hapticsEnabled)
                        }
                    }
                    .tint(.purple)
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.hapticsEnabled)
                } header: {
                    Text("Haptic Feedback")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Provides tactile responses when you interact with buttons and controls throughout the app.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Widget Display Section
                Section {
                    @Bindable var settings = settingsManager

                    Picker("First Metric", selection: $settings.settings.widgetMetric1) {
                        ForEach(MetricType.allCases, id: \.self) { metric in
                            Label(metric.rawValue, systemImage: metric.icon)
                                .tag(metric)
                        }
                    }
                    .pickerStyle(.menu)
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.widgetMetric1) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }

                    Picker("Second Metric", selection: $settings.settings.widgetMetric2) {
                        ForEach(MetricType.allCases, id: \.self) { metric in
                            Label(metric.rawValue, systemImage: metric.icon)
                                .tag(metric)
                        }
                    }
                    .pickerStyle(.menu)
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.widgetMetric2) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                } header: {
                    Text("Widget Display")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Choose which two metrics to display in home screen widgets. Changes apply to all widget sizes.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Picture-in-Picture Display Section
                Section {
                    @Bindable var settings = settingsManager

                    Picker("Metric", selection: $settings.settings.pipMetric) {
                        ForEach(MetricType.allCases, id: \.self) { metric in
                            Label(metric.rawValue, systemImage: metric.icon)
                                .tag(metric)
                        }
                    }
                    .pickerStyle(.menu)
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.pipMetric) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                } header: {
                    Text("Picture-in-Picture Display")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Choose which metric to display when using Picture-in-Picture mode.")
                        .font(.system(size: 13, design: .rounded))
                }

                // Actions Section
                Section {
                    Button(role: .destructive, action: {
                        withAnimation {
                            metricsManager.clearHistory()
                        }
                    }) {
                        Label("Clear History", systemImage: "trash")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .sensoryFeedback(.success, trigger: metricsManager.cpuHistory.count) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                } header: {
                    Text("Data")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Remove all collected performance data.")
                        .font(.system(size: 13, design: .rounded))
                }

                // About Section
                Section {
                    LabeledContent {
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, design: .rounded))
                    } label: {
                        Text("Version")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }

                    LabeledContent {
                        Text("100")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, design: .rounded))
                    } label: {
                        Text("Build")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }

                    LabeledContent {
                        Text("iOS 17.0+")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, design: .rounded))
                    } label: {
                        Text("Requires")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                } header: {
                    Text("About")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func colorForMetric(_ metric: MetricType) -> Color {
        switch metric {
        case .cpuUser: return .orange
        case .cpuSystem: return .red
        case .cpuTotal: return .blue
        case .memoryActive: return .green
        case .memoryInactive: return .yellow
        case .memoryWired: return .purple
        case .memoryCompressed: return .pink
        case .memoryTotal: return .green
        case .network: return .orange
        case .storage: return .purple
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    SettingsView()
        .environment(SettingsManager.shared)
        .environment(MetricsManager.shared)
}
