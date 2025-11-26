//
//  SettingsView.swift
//  ActivityMonitor
//
//  Settings screen for customizing metrics and preferences (iOS 17+ design)
//

import SwiftUI
import CoreMotion
import AVFoundation
import LocalAuthentication
import CoreLocation

@available(iOS 17.0, *)
struct SettingsView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var fileToShare: URL?

    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section {
                    @Bindable var settings = settingsManager

                    // Custom segmented control with liquid glass styling
                    HStack(spacing: 4) {
                        // Light Theme Button
                        Button {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0.1)) {
                                settings.settings.appTheme = .light
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 14))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Light")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(settings.settings.appTheme == .light ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if settings.settings.appTheme == .light {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.blue.gradient)
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.3)
                                    }
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        // Dark Theme Button
                        Button {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0.1)) {
                                settings.settings.appTheme = .dark
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Dark")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(settings.settings.appTheme == .dark ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if settings.settings.appTheme == .dark {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.blue.gradient)
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.3)
                                    }
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        // Auto Theme Button
                        Button {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0.1)) {
                                settings.settings.appTheme = .auto
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "circle.lefthalf.filled")
                                    .font(.system(size: 14))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Auto")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(settings.settings.appTheme == .auto ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if settings.settings.appTheme == .auto {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.blue.gradient)
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.3)
                                    }
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(4)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.regularMaterial)
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    .linearGradient(
                                        colors: [
                                            .white.opacity(0.3),
                                            .white.opacity(0.1),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    }
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
                    // CPU
                    MetricToggle(metric: .cpuTotal)
                    if settingsManager.isMetricEnabled(.cpuTotal) {
                        MetricToggle(metric: .cpuUser, isSubItem: true)
                        MetricToggle(metric: .cpuSystem, isSubItem: true)
                    }

                    // Memory
                    MetricToggle(metric: .memoryTotal)
                    if settingsManager.isMetricEnabled(.memoryTotal) {
                        MetricToggle(metric: .memoryActive, isSubItem: true)
                        MetricToggle(metric: .memoryInactive, isSubItem: true)
                        MetricToggle(metric: .memoryWired, isSubItem: true)
                        MetricToggle(metric: .memoryCompressed, isSubItem: true)
                    }

                    // Network
                    MetricToggle(metric: .networkTotal)
                    if settingsManager.isMetricEnabled(.networkTotal) {
                        MetricToggle(metric: .networkDownload, isSubItem: true)
                        MetricToggle(metric: .networkUpload, isSubItem: true)
                    }

                    // Disk I/O
                    MetricToggle(metric: .diskIOTotal)
                    if settingsManager.isMetricEnabled(.diskIOTotal) {
                        MetricToggle(metric: .diskIORead, isSubItem: true)
                        MetricToggle(metric: .diskIOWrite, isSubItem: true)
                    }

                    // Storage
                    MetricToggle(metric: .storage)

                    // Battery
                    MetricToggle(metric: .battery)
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
                    Button(action: {
                        if let fileURL = metricsManager.exportDataAsCSV() {
                            fileToShare = fileURL
                            showShareSheet = true
                        }
                    }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }

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
                    Text("Export collected data as CSV or remove all performance data.")
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
            .sheet(isPresented: $showShareSheet) {
                if let fileURL = fileToShare {
                    ShareSheet(items: [fileURL])
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
        case .networkDownload: return .green
        case .networkUpload: return .blue
        case .networkTotal: return .orange
        case .storage: return .purple
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }
}

// MARK: - Metric Toggle Component

@available(iOS 17.0, *)
struct MetricToggle: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(MetricsManager.self) private var metricsManager

    let metric: MetricType
    var isSubItem: Bool = false

    var body: some View {
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
        .padding(.leading, isSubItem ? 20 : 0)
        .sensoryFeedback(.selection, trigger: settingsManager.isMetricEnabled(metric)) { _, _ in
            settingsManager.settings.hapticsEnabled
        }
    }

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
        case .networkDownload: return .green
        case .networkUpload: return .blue
        case .networkTotal: return .orange
        case .storage: return .purple
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }
}

// MARK: - Device Info View

@available(iOS 17.0, *)
struct DeviceInfoView: View {
    let gpuInfo: GPUInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // GPU Information
                Section {
                    InfoDetailRow(label: "GPU Name", value: gpuInfo.name, icon: "cpu.fill")
                    InfoDetailRow(label: "GPU Family", value: gpuInfo.family, icon: "rectangle.3.group.fill")
                    InfoDetailRow(label: "Max Threads", value: "\(gpuInfo.maxThreadsPerThreadgroup)", icon: "arrow.triangle.branch")
                    InfoDetailRow(label: "GPU Memory", value: String(format: "%.2f GB", gpuInfo.gpuMemoryGB), icon: "memorychip.fill")
                    InfoDetailRow(label: "Max Working Set", value: String(format: "%.2f GB", gpuInfo.maxWorkingSetGB), icon: "square.stack.3d.up.fill")
                    InfoDetailRow(label: "Unified Memory", value: gpuInfo.hasUnifiedMemory ? "Yes" : "No", icon: "cpu.fill")

                    if gpuInfo.supportsRaytracing {
                        InfoDetailRow(label: "Ray Tracing", value: "Supported", icon: "light.beacon.max.fill")
                    }

                    if gpuInfo.supportsMeshShaders {
                        InfoDetailRow(label: "Mesh Shaders", value: "Supported", icon: "waveform")
                    }
                } header: {
                    HStack {
                        Image(systemName: "gpu")
                            .foregroundStyle(.blue.gradient)
                        Text("GPU Information")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                // Neural Engine Information
                if let neuralEngine = gpuInfo.neuralEngineGeneration {
                    Section {
                        InfoDetailRow(label: "Neural Engine", value: neuralEngine, icon: "brain.head.profile")

                        if let cores = gpuInfo.neuralEngineCores {
                            InfoDetailRow(label: "ANE Cores", value: "\(cores)", icon: "cpu")
                        }
                    } header: {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundStyle(.purple.gradient)
                            Text("Neural Engine (ANE)")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    } footer: {
                        Text("The Neural Engine accelerates machine learning tasks and Core ML operations.")
                            .font(.system(size: 13, design: .rounded))
                    }
                }

                // Capabilities
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        CapabilityBadge(title: "Metal", supported: true)
                        CapabilityBadge(title: "Metal 3", supported: gpuInfo.family.contains("Apple 8") || gpuInfo.family.contains("Apple 9"))
                        CapabilityBadge(title: "Ray Tracing", supported: gpuInfo.supportsRaytracing)
                        CapabilityBadge(title: "Mesh Shaders", supported: gpuInfo.supportsMeshShaders)
                        CapabilityBadge(title: "Core ML", supported: gpuInfo.neuralEngineGeneration != nil)
                        CapabilityBadge(title: "Unified Memory", supported: gpuInfo.hasUnifiedMemory)
                    }
                    .padding(.vertical, 8)
                } header: {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundStyle(.green.gradient)
                        Text("Capabilities")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
            .navigationTitle("Device Information")
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
}

struct InfoDetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.system(size: 15, weight: .medium, design: .rounded))
            Spacer()
            Text(value)
                .font(.system(size: 15, design: .monospaced))
        }
    }
}

struct CapabilityBadge: View {
    let title: String
    let supported: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: supported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(supported ? .green : .gray)
                .font(.system(size: 16))

            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(supported ? .primary : .secondary)

            Spacer()
        }
    }
}

// MARK: - Storage Optimization View

@available(iOS 17.0, *)
struct StorageOptimizationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storageCategories: [StorageCategory] = []
    @State private var isCleaning = false
    @State private var showCleaningResult = false
    @State private var cleaningResult: (totalCleaned: UInt64, categoriesCleaned: Int)?
    @State private var isRefreshing = false

    private let storageManager = StorageManager.shared

    var totalSize: UInt64 {
        storageCategories.reduce(0) { $0 + $1.size }
    }

    var cleanableSize: UInt64 {
        storageCategories.filter { $0.canDelete }.reduce(0) { $0 + $1.size }
    }

    var body: some View {
        NavigationStack {
            List {
                // Summary Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total App Storage")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(formatSize(totalSize))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange.gradient)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.vertical, 8)

                    HStack {
                        Label("Cleanable", systemImage: "trash.fill")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.green)
                        Spacer()
                        Text(formatSize(cleanableSize))
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.green)
                    }
                }

                // Storage Categories
                Section {
                    ForEach(storageCategories) { category in
                        StorageCategoryRow(
                            category: category,
                            onClean: {
                                cleanCategory(category)
                            }
                        )
                    }
                } header: {
                    Text("Storage Breakdown")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                // Actions
                Section {
                    Button(action: {
                        cleanAllCategories()
                    }) {
                        HStack {
                            Label("Clean All", systemImage: isCleaning ? "arrow.triangle.2.circlepath" : "trash.circle.fill")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .symbolEffect(.pulse, isActive: isCleaning)

                            if isCleaning {
                                Spacer()
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(cleanableSize > 0 ? Color.green.gradient : Color.gray.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isCleaning || cleanableSize == 0)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Storage Optimization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        refreshStorage()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .opacity(isRefreshing ? 0.5 : 1.0)
                    }
                    .disabled(isRefreshing)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .onAppear {
                refreshStorage()
            }
            .alert("Cleaning Complete", isPresented: $showCleaningResult) {
                Button("OK", role: .cancel) {
                    refreshStorage()
                }
            } message: {
                if let result = cleaningResult {
                    Text("Cleaned \(formatSize(result.totalCleaned)) from \(result.categoriesCleaned) categories")
                }
            }
        }
    }

    private func refreshStorage() {
        isRefreshing = true
        Task { @MainActor in
            storageCategories = StorageManager.shared.analyzeStorage()
            isRefreshing = false
        }
    }

    private func cleanCategory(_ category: StorageCategory) {
        isCleaning = true
        Task { @MainActor in
            let cleaned = StorageManager.shared.cleanCategory(category)
            isCleaning = false
            cleaningResult = (cleaned, 1)
            showCleaningResult = true
        }
    }

    private func cleanAllCategories() {
        isCleaning = true
        Task { @MainActor in
            let result = StorageManager.shared.cleanAll()
            isCleaning = false
            cleaningResult = result
            showCleaningResult = true
        }
    }

    private func formatSize(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        let mb = Double(bytes) / 1_048_576.0
        let kb = Double(bytes) / 1_024.0

        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.1f MB", mb)
        } else if kb >= 1.0 {
            return String(format: "%.0f KB", kb)
        } else {
            return "\(bytes) B"
        }
    }
}

struct StorageCategoryRow: View {
    let category: StorageCategory
    let onClean: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 20))
                .foregroundStyle(category.canDelete ? .orange : .gray)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))

                if category.sizeMB >= 1.0 {
                    Text(String(format: "%.1f MB", category.sizeMB))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.secondary)
                } else {
                    Text(String(format: "%.0f KB", Double(category.size) / 1024.0))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if category.canDelete {
                Button(action: onClean) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red.gradient)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Performance View

@available(iOS 17.0, *)
struct PerformanceView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @State private var isOptimizing = false
    @State private var showOptimizationResult = false
    @State private var optimizationResult: (freedMemory: Double, clearedCache: Double)?
    @State private var showStorageOptimization = false

    var body: some View {
        List {
            // Quick Optimization Section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quick Optimization")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Free up memory and clear cache")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.yellow.gradient)
                    }

                    Button(action: optimizePerformance) {
                        HStack {
                            Label(isOptimizing ? "Optimizing..." : "Optimize Now", systemImage: isOptimizing ? "arrow.triangle.2.circlepath" : "bolt.fill")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))

                            if isOptimizing {
                                Spacer()
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isOptimizing ? Color.gray.gradient : Color.yellow.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isOptimizing)
                }
                .padding(.vertical, 8)
            } header: {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow.gradient)
                    Text("Memory & Cache")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Storage Optimization Section
            Section {
                Button {
                    showStorageOptimization = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage Optimization")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("Analyze and clean app storage")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                HStack {
                    Image(systemName: "internaldrive.fill")
                        .foregroundStyle(.orange.gradient)
                    Text("Storage Management")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Current Metrics Overview
            Section {
                MetricOverviewRow(
                    label: "CPU Usage",
                    value: String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime + metricsManager.currentMetrics.cpu.systemTime),
                    icon: "cpu.fill",
                    color: .blue
                )

                MetricOverviewRow(
                    label: "Memory Used",
                    value: String(format: "%.1f GB", metricsManager.currentMetrics.memory.usedGB),
                    icon: "memorychip.fill",
                    color: .green
                )

                MetricOverviewRow(
                    label: "Storage Used",
                    value: String(format: "%.1f%%", metricsManager.currentMetrics.storage.usagePercentage),
                    icon: "internaldrive.fill",
                    color: .orange
                )
            } header: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.blue.gradient)
                    Text("Current Status")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
        }
        .sheet(isPresented: $showStorageOptimization) {
            StorageOptimizationView()
        }
        .alert("Optimization Complete", isPresented: $showOptimizationResult) {
            Button("OK", role: .cancel) { }
        } message: {
            if let result = optimizationResult {
                Text("Freed \(String(format: "%.2f", result.freedMemory)) GB of memory\nCleared \(String(format: "%.2f", result.clearedCache)) GB of cache")
            }
        }
    }

    private func optimizePerformance() {
        isOptimizing = true
        Task { @MainActor in
            let result = await metricsManager.optimizePerformance()
            optimizationResult = result
            isOptimizing = false
            showOptimizationResult = true
        }
    }
}

struct MetricOverviewRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(color.gradient)
            }

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Device Info Tab View

@available(iOS 17.0, *)
struct DeviceInfoTabView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @State private var gpuInfo: GPUInfo = .zero
    @State private var networkDetails: NetworkDetails = .zero

    private var memoryInfo: MemoryMetrics {
        metricsManager.currentMetrics.memory
    }

    private var storageInfo: StorageMetrics {
        metricsManager.currentMetrics.storage
    }

    var body: some View {
        List {
            // System Information
            Section {
                InfoDetailRow(label: "Device Model", value: getDeviceModel(), icon: "iphone")
                InfoDetailRow(label: "iOS Version", value: getIOSVersion(), icon: "apple.logo")
                InfoDetailRow(label: "Device Name", value: UIDevice.current.name, icon: "phone.fill")
            } header: {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue.gradient)
                    Text("System Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // CPU Information
            Section {
                InfoDetailRow(label: "CPU Model", value: getCPUModel(), icon: "cpu")
                InfoDetailRow(label: "CPU Cores", value: "\(ProcessInfo.processInfo.processorCount)", icon: "circle.grid.cross.fill")
                InfoDetailRow(label: "Physical Cores", value: "\(getPhysicalCores())", icon: "circle.grid.2x2.fill")

                if let frequency = getCPUFrequency() {
                    InfoDetailRow(label: "CPU Frequency", value: frequency, icon: "waveform.path.ecg")
                }

                if let l1Cache = getL1CacheSize() {
                    InfoDetailRow(label: "L1 Cache", value: l1Cache, icon: "speedometer")
                }

                if let l2Cache = getL2CacheSize() {
                    InfoDetailRow(label: "L2 Cache", value: l2Cache, icon: "gauge.medium")
                }

                if let l3Cache = getL3CacheSize() {
                    InfoDetailRow(label: "L3 Cache", value: l3Cache, icon: "gauge.high")
                }

                if let cacheLineSize = getCacheLineSize() {
                    InfoDetailRow(label: "Cache Line Size", value: "\(cacheLineSize) bytes", icon: "lineweight")
                }

                InfoDetailRow(label: "Byte Order", value: getByteOrder(), icon: "arrow.left.arrow.right")
            } header: {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundStyle(.blue.gradient)
                    Text("CPU Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Memory Information
            Section {
                InfoDetailRow(label: "Total Memory", value: String(format: "%.2f GB", memoryInfo.totalGB), icon: "memorychip")
                InfoDetailRow(label: "Physical Memory", value: getPhysicalMemory(), icon: "memorychip.fill")
                InfoDetailRow(label: "Memory Type", value: getMemoryType(), icon: "chevron.left.forwardslash.chevron.right")

                if let speed = getMemorySpeed() {
                    InfoDetailRow(label: "Memory Speed", value: speed, icon: "speedometer")
                }

                InfoDetailRow(label: "Page Size", value: "\(getPageSize()) KB", icon: "doc.text")
                InfoDetailRow(label: "Total Pages", value: String(format: "%llu", getTotalPages()), icon: "square.grid.3x3")
                InfoDetailRow(label: "Memory Pressure", value: getMemoryPressure(), icon: "gauge")
            } header: {
                HStack {
                    Image(systemName: "memorychip")
                        .foregroundStyle(.green.gradient)
                    Text("Memory Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Memory Statistics & Errors
            Section {
                InfoDetailRow(label: "Page Faults", value: getPageFaultCount(), icon: "exclamationmark.triangle")

                let pageIO = getPageInOutCount()
                InfoDetailRow(label: "Page-Ins", value: pageIO.pageIns, icon: "arrow.down.circle")
                InfoDetailRow(label: "Page-Outs", value: pageIO.pageOuts, icon: "arrow.up.circle")

                InfoDetailRow(label: "Copy-on-Write Faults", value: getCopyOnWriteFaults(), icon: "doc.on.doc")
                InfoDetailRow(label: "Free Pages", value: getFreePageCount(), icon: "square.stack")
                InfoDetailRow(label: "Purgeable Pages", value: getPurgeablePageCount(), icon: "trash.square")
            } header: {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundStyle(.purple.gradient)
                    Text("Memory Statistics")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Page faults and statistics since system boot. High page-out counts may indicate memory pressure.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Storage Information
            Section {
                InfoDetailRow(label: "Total Storage", value: String(format: "%.2f GB", storageInfo.totalGB), icon: "internaldrive")
                InfoDetailRow(label: "Used Storage", value: String(format: "%.2f GB", storageInfo.usedGB), icon: "internaldrive.fill")
                InfoDetailRow(label: "Free Storage", value: String(format: "%.2f GB", storageInfo.freeGB), icon: "internaldrive")
                InfoDetailRow(label: "Usage", value: String(format: "%.1f%%", storageInfo.usagePercentage), icon: "chart.bar.fill")
            } header: {
                HStack {
                    Image(systemName: "internaldrive")
                        .foregroundStyle(.orange.gradient)
                    Text("Storage Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Network Information
            Section {
                if let ipv4 = networkDetails.ipv4Address, !ipv4.isEmpty {
                    InfoDetailRow(label: "IPv4 Address", value: ipv4, icon: "network")
                }

                if let ipv6 = networkDetails.ipv6Address, !ipv6.isEmpty {
                    InfoDetailRow(label: "IPv6 Address", value: ipv6, icon: "network")
                }

                if let externalIP = networkDetails.externalIP, !externalIP.isEmpty {
                    InfoDetailRow(label: "External IP", value: externalIP, icon: "globe")
                }

                if let gateway = networkDetails.defaultGateway, !gateway.isEmpty {
                    InfoDetailRow(label: "Gateway", value: gateway, icon: "arrow.triangle.swap")
                }

                if !networkDetails.dnsServers.isEmpty {
                    InfoDetailRow(label: "DNS Servers", value: networkDetails.dnsServers.joined(separator: ", "), icon: "server.rack")
                }

                if let ssid = networkDetails.ssid, !ssid.isEmpty {
                    InfoDetailRow(label: "WiFi SSID", value: ssid, icon: "wifi")

                    if let bssid = networkDetails.bssid {
                        InfoDetailRow(label: "WiFi BSSID", value: bssid, icon: "dot.radiowaves.left.and.right")
                    }

                    if let band = networkDetails.wifiBand {
                        InfoDetailRow(label: "WiFi Band", value: band, icon: "waveform")
                    }

                    if let rssi = networkDetails.rssi {
                        InfoDetailRow(label: "Signal Strength", value: "\(rssi) dBm", icon: "antenna.radiowaves.left.and.right")
                    }

                    if let security = networkDetails.securityType {
                        InfoDetailRow(label: "Security", value: security, icon: "lock.fill")
                    }
                }

                if let carrier = networkDetails.carrierName, !carrier.isEmpty {
                    InfoDetailRow(label: "Carrier", value: carrier, icon: "antenna.radiowaves.left.and.right")

                    if let connectionType = networkDetails.connectionType {
                        InfoDetailRow(label: "Connection Type", value: connectionType, icon: "antenna.radiowaves.left.and.right.circle")
                    }

                    if let band = networkDetails.cellularBand {
                        InfoDetailRow(label: "Cellular Band", value: band, icon: "waveform.path")
                    }

                    if let mcc = networkDetails.mobileCountryCode {
                        InfoDetailRow(label: "MCC", value: mcc, icon: "globe.americas.fill")
                    }

                    if let mnc = networkDetails.mobileNetworkCode {
                        InfoDetailRow(label: "MNC", value: mnc, icon: "network")
                    }
                }

                InfoDetailRow(label: "VPN Active", value: networkDetails.isVPNActive ? "Yes" : "No", icon: "lock.shield.fill")
                InfoDetailRow(label: "Proxy Enabled", value: networkDetails.isProxyEnabled ? "Yes" : "No", icon: "arrow.left.arrow.right.circle.fill")
            } header: {
                HStack {
                    Image(systemName: "network")
                        .foregroundStyle(.cyan.gradient)
                    Text("Network Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // GPU Information
            Section {
                InfoDetailRow(label: "GPU Name", value: gpuInfo.name, icon: "cpu.fill")
                InfoDetailRow(label: "GPU Family", value: gpuInfo.family, icon: "rectangle.3.group.fill")
                InfoDetailRow(label: "Max Threads", value: "\(gpuInfo.maxThreadsPerThreadgroup)", icon: "arrow.triangle.branch")
                InfoDetailRow(label: "GPU Memory", value: String(format: "%.2f GB", gpuInfo.gpuMemoryGB), icon: "memorychip.fill")
                InfoDetailRow(label: "Max Working Set", value: String(format: "%.2f GB", gpuInfo.maxWorkingSetGB), icon: "square.stack.3d.up.fill")
                InfoDetailRow(label: "Unified Memory", value: gpuInfo.hasUnifiedMemory ? "Yes" : "No", icon: "cpu.fill")

                if gpuInfo.supportsRaytracing {
                    InfoDetailRow(label: "Ray Tracing", value: "Supported", icon: "light.beacon.max.fill")
                }

                if gpuInfo.supportsMeshShaders {
                    InfoDetailRow(label: "Mesh Shaders", value: "Supported", icon: "mesh.fill")
                }
            } header: {
                HStack {
                    Image(systemName: "gpu")
                        .foregroundStyle(.purple.gradient)
                    Text("GPU Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Neural Engine Information
            if let neuralEngine = gpuInfo.neuralEngineGeneration {
                Section {
                    InfoDetailRow(label: "Neural Engine", value: neuralEngine, icon: "brain.head.profile")

                    if let cores = gpuInfo.neuralEngineCores {
                        InfoDetailRow(label: "ANE Cores", value: "\(cores)", icon: "cpu")
                    }

                    InfoDetailRow(label: "Performance", value: "15.8 TOPS (typical)", icon: "speedometer")
                } header: {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(.pink.gradient)
                        Text("Neural Engine (ANE)")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("The Neural Engine accelerates machine learning tasks and Core ML operations.")
                        .font(.system(size: 13, design: .rounded))
                }
            }

            // Capabilities
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    CapabilityBadge(title: "Metal", supported: true)
                    CapabilityBadge(title: "Metal 3", supported: gpuInfo.family.contains("Apple 8") || gpuInfo.family.contains("Apple 9"))
                    CapabilityBadge(title: "Ray Tracing", supported: gpuInfo.supportsRaytracing)
                    CapabilityBadge(title: "Mesh Shaders", supported: gpuInfo.supportsMeshShaders)
                    CapabilityBadge(title: "Core ML", supported: gpuInfo.neuralEngineGeneration != nil)
                    CapabilityBadge(title: "Unified Memory", supported: gpuInfo.hasUnifiedMemory)
                }
                .padding(.vertical, 8)
            } header: {
                HStack {
                    Image(systemName: "checklist")
                        .foregroundStyle(.green.gradient)
                    Text("Capabilities")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Display Information
            Section {
                InfoDetailRow(label: "Screen Resolution", value: getScreenResolution(), icon: "rectangle.grid.1x2")
                InfoDetailRow(label: "Screen Size", value: getScreenSize(), icon: "iphone")
                InfoDetailRow(label: "Pixel Density", value: getPixelsPerInch(), icon: "square.grid.3x3")
                InfoDetailRow(label: "Refresh Rate", value: getRefreshRate(), icon: "waveform")
                InfoDetailRow(label: "Brightness", value: getScreenBrightness(), icon: "sun.max.fill")
                InfoDetailRow(label: "HDR Support", value: supportsHDR(), icon: "tv")
            } header: {
                HStack {
                    Image(systemName: "display")
                        .foregroundStyle(.indigo.gradient)
                    Text("Display Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // System/Kernel Information
            Section {
                InfoDetailRow(label: "Kernel Version", value: getKernelVersion(), icon: "gearshape.2")
                InfoDetailRow(label: "System Uptime", value: getSystemUptime(), icon: "clock")
                InfoDetailRow(label: "Boot Time", value: getBootTime(), icon: "power")
                InfoDetailRow(label: "Architecture", value: getSystemArchitecture(), icon: "cpu")
                InfoDetailRow(label: "Hostname", value: getHostname(), icon: "network")
                InfoDetailRow(label: "Time Zone", value: getTimeZone(), icon: "clock.badge")
            } header: {
                HStack {
                    Image(systemName: "gearshape.2.fill")
                        .foregroundStyle(.gray.gradient)
                    Text("System Information")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Battery & Power Information
            Section {
                InfoDetailRow(label: "Power Source", value: getPowerSource(), icon: "bolt.fill")
                InfoDetailRow(label: "Low Power Mode", value: getLowPowerMode(), icon: "battery.25")
                InfoDetailRow(label: "Thermal State", value: getThermalState(), icon: "thermometer.medium")
            } header: {
                HStack {
                    Image(systemName: "bolt.circle.fill")
                        .foregroundStyle(.yellow.gradient)
                    Text("Power & Thermal")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Thermal state indicates device temperature. Critical state may cause performance throttling.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Graphics Details
            Section {
                InfoDetailRow(label: "Metal Version", value: getMetalVersion(), icon: "cube.transparent")
                InfoDetailRow(label: "GPU Architecture", value: getGPUFamily(), icon: "cpu.fill")
            } header: {
                HStack {
                    Image(systemName: "cube.transparent.fill")
                        .foregroundStyle(.teal.gradient)
                    Text("Graphics Details")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Storage Details
            Section {
                InfoDetailRow(label: "File System", value: getFileSystemType(), icon: "folder.fill")
                InfoDetailRow(label: "Encryption", value: getEncryptionStatus(), icon: "lock.shield.fill")
            } header: {
                HStack {
                    Image(systemName: "internaldrive.fill")
                        .foregroundStyle(.brown.gradient)
                    Text("Storage Details")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Locale & Region
            Section {
                InfoDetailRow(label: "Current Locale", value: getCurrentLocale(), icon: "globe")
                InfoDetailRow(label: "Languages", value: getPreferredLanguages(), icon: "character.bubble")
                InfoDetailRow(label: "Region", value: getRegionFormat(), icon: "map")
                InfoDetailRow(label: "Calendar", value: getCalendarType(), icon: "calendar")
                InfoDetailRow(label: "Measurement", value: getMeasurementSystem(), icon: "ruler")
            } header: {
                HStack {
                    Image(systemName: "globe.americas.fill")
                        .foregroundStyle(.blue.gradient)
                    Text("Locale & Region")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Security Features
            Section {
                InfoDetailRow(label: "Secure Enclave", value: hasSecureEnclave(), icon: "lock.shield")
                InfoDetailRow(label: "Data Protection", value: getDataProtectionLevel(), icon: "checkmark.shield.fill")
            } header: {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.red.gradient)
                    Text("Security Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Audio Features
            Section {
                InfoDetailRow(label: "Spatial Audio", value: getSpatialAudioSupport(), icon: "hifispeaker.2")
            } header: {
                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(.pink.gradient)
                    Text("Audio Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            Task { @MainActor in
                let collector = SystemMetricsCollector()
                gpuInfo = collector.collectGPUInfo()
                networkDetails = collector.collectNetworkDetails()
            }
        }
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return modelCode ?? "Unknown"
    }

    private func getIOSVersion() -> String {
        let version = UIDevice.current.systemVersion
        return "iOS \(version)"
    }

    private func getCPUModel() -> String {
        // Fallback to device model-based CPU identification
        let deviceModel = getDeviceModel()

        if deviceModel.contains("iPhone") {
            if deviceModel.contains("16,") || deviceModel.contains("17,") {
                return "Apple A17 Pro / A18"
            } else if deviceModel.contains("15,") {
                return "Apple A16 Bionic"
            } else if deviceModel.contains("14,") {
                return "Apple A15 Bionic"
            } else if deviceModel.contains("13,") {
                return "Apple A14 Bionic"
            }
            return "Apple A-Series"
        } else if deviceModel.contains("iPad") {
            if deviceModel.contains("14,") || deviceModel.contains("15,") {
                return "Apple M2"
            } else if deviceModel.contains("13,") {
                return "Apple M1"
            }
            return "Apple Silicon"
        }

        return "ARM64"
    }

    // MARK: - CPU Helper Functions

    private func getPhysicalCores() -> Int {
        var physicalCores: Int = 0
        var size = MemoryLayout<Int>.size
        sysctlbyname("hw.physicalcpu", &physicalCores, &size, nil, 0)
        return physicalCores > 0 ? physicalCores : ProcessInfo.processInfo.processorCount
    }

    private func getCPUFrequency() -> String? {
        var frequency: Int64 = 0
        var size = MemoryLayout<Int64>.size

        // Try hw.cpufrequency_max first
        if sysctlbyname("hw.cpufrequency_max", &frequency, &size, nil, 0) == 0, frequency > 0 {
            let ghz = Double(frequency) / 1_000_000_000.0
            return String(format: "%.2f GHz", ghz)
        }

        // Try hw.cpufrequency
        if sysctlbyname("hw.cpufrequency", &frequency, &size, nil, 0) == 0, frequency > 0 {
            let ghz = Double(frequency) / 1_000_000_000.0
            return String(format: "%.2f GHz", ghz)
        }

        return nil
    }

    private func getL1CacheSize() -> String? {
        var l1iCache: Int64 = 0
        var l1dCache: Int64 = 0
        var size = MemoryLayout<Int64>.size

        sysctlbyname("hw.l1icachesize", &l1iCache, &size, nil, 0)
        sysctlbyname("hw.l1dcachesize", &l1dCache, &size, nil, 0)

        if l1iCache > 0 || l1dCache > 0 {
            let totalKB = (l1iCache + l1dCache) / 1024
            return "\(totalKB) KB"
        }

        return nil
    }

    private func getL2CacheSize() -> String? {
        var l2Cache: Int64 = 0
        var size = MemoryLayout<Int64>.size

        if sysctlbyname("hw.l2cachesize", &l2Cache, &size, nil, 0) == 0, l2Cache > 0 {
            let mb = Double(l2Cache) / 1_048_576.0
            if mb >= 1.0 {
                return String(format: "%.1f MB", mb)
            } else {
                return "\(l2Cache / 1024) KB"
            }
        }

        return nil
    }

    private func getL3CacheSize() -> String? {
        var l3Cache: Int64 = 0
        var size = MemoryLayout<Int64>.size

        if sysctlbyname("hw.l3cachesize", &l3Cache, &size, nil, 0) == 0, l3Cache > 0 {
            let mb = Double(l3Cache) / 1_048_576.0
            return String(format: "%.1f MB", mb)
        }

        return nil
    }

    private func getCacheLineSize() -> Int? {
        var cacheLineSize: Int64 = 0
        var size = MemoryLayout<Int64>.size

        if sysctlbyname("hw.cachelinesize", &cacheLineSize, &size, nil, 0) == 0, cacheLineSize > 0 {
            return Int(cacheLineSize)
        }

        return nil
    }

    private func getByteOrder() -> String {
        var byteOrder: Int = 0
        var size = MemoryLayout<Int>.size

        if sysctlbyname("hw.byteorder", &byteOrder, &size, nil, 0) == 0 {
            return byteOrder == 1234 ? "Little Endian" : "Big Endian"
        }

        return "Unknown"
    }

    // MARK: - Memory Helper Functions

    private func getPhysicalMemory() -> String {
        var memsize: UInt64 = 0
        var size = MemoryLayout<UInt64>.size

        if sysctlbyname("hw.memsize", &memsize, &size, nil, 0) == 0 {
            let gb = Double(memsize) / 1_073_741_824.0
            return String(format: "%.2f GB", gb)
        }

        return "Unknown"
    }

    private func getPageSize() -> Int {
        var pageSize: Int = 0
        var size = MemoryLayout<Int>.size

        if sysctlbyname("hw.pagesize", &pageSize, &size, nil, 0) == 0 {
            return pageSize / 1024 // Convert to KB
        }

        return Int(vm_page_size) / 1024
    }

    private func getTotalPages() -> UInt64 {
        var memsize: UInt64 = 0
        var size = MemoryLayout<UInt64>.size

        sysctlbyname("hw.memsize", &memsize, &size, nil, 0)

        let pageSize = getPageSize() * 1024 // Convert back to bytes
        return memsize / UInt64(pageSize)
    }

    private func getMemoryPressure() -> String {
        // Get memory pressure level
        var pressureLevel: Int32 = 0
        var size = MemoryLayout<Int32>.size

        if sysctlbyname("kern.memorystatus_vm_pressure_level", &pressureLevel, &size, nil, 0) == 0 {
            switch pressureLevel {
            case 1:
                return "Normal"
            case 2:
                return "Warning"
            case 4:
                return "Critical"
            default:
                return "Normal"
            }
        }

        // Fallback: calculate based on usage percentage
        let usagePercentage = memoryInfo.usagePercentage
        if usagePercentage < 60 {
            return "Normal"
        } else if usagePercentage < 80 {
            return "Warning"
        } else {
            return "Critical"
        }
    }

    private func getMemoryType() -> String {
        // iOS doesn't expose memory type directly, so we infer from device model
        let deviceModel = getDeviceModel()

        // iPhone models and their memory types
        if deviceModel.contains("iPhone16") || deviceModel.contains("iPhone17") {
            return "LPDDR5X"
        } else if deviceModel.contains("iPhone15") {
            return "LPDDR5"
        } else if deviceModel.contains("iPhone14") || deviceModel.contains("iPhone13") {
            return "LPDDR4X"
        } else if deviceModel.contains("iPad") {
            if deviceModel.contains("iPad16") || deviceModel.contains("iPad15") {
                return "LPDDR5X"
            } else if deviceModel.contains("iPad14") || deviceModel.contains("iPad13") {
                return "LPDDR5"
            } else {
                return "LPDDR4X"
            }
        }

        return "LPDDR4 or later"
    }

    private func getMemorySpeed() -> String? {
        // Estimate based on memory type
        let memType = getMemoryType()

        switch memType {
        case "LPDDR5X":
            return "~8533 MT/s"
        case "LPDDR5":
            return "~6400 MT/s"
        case "LPDDR4X":
            return "~4266 MT/s"
        default:
            return nil
        }
    }

    private func getPageFaultCount() -> String {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let totalFaults = UInt64(vmStats.faults)
            if totalFaults > 1_000_000 {
                let millions = Double(totalFaults) / 1_000_000.0
                return String(format: "%.2f M", millions)
            } else if totalFaults > 1_000 {
                let thousands = Double(totalFaults) / 1_000.0
                return String(format: "%.1f K", thousands)
            }
            return "\(totalFaults)"
        }

        return "0"
    }

    private func getPageInOutCount() -> (pageIns: String, pageOuts: String) {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let pageIns = UInt64(vmStats.pageins)
            let pageOuts = UInt64(vmStats.pageouts)

            let pageInsStr: String
            if pageIns > 1_000_000 {
                pageInsStr = String(format: "%.2f M", Double(pageIns) / 1_000_000.0)
            } else if pageIns > 1_000 {
                pageInsStr = String(format: "%.1f K", Double(pageIns) / 1_000.0)
            } else {
                pageInsStr = "\(pageIns)"
            }

            let pageOutsStr: String
            if pageOuts > 1_000_000 {
                pageOutsStr = String(format: "%.2f M", Double(pageOuts) / 1_000_000.0)
            } else if pageOuts > 1_000 {
                pageOutsStr = String(format: "%.1f K", Double(pageOuts) / 1_000.0)
            } else {
                pageOutsStr = "\(pageOuts)"
            }

            return (pageInsStr, pageOutsStr)
        }

        return ("0", "0")
    }

    private func getFreePageCount() -> String {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let freePages = UInt64(vmStats.free_count)
            let pageSize = getPageSize() * 1024 // in bytes
            let freeMB = Double(freePages * UInt64(pageSize)) / 1_048_576.0
            return String(format: "%.0f MB (%llu pages)", freeMB, freePages)
        }

        return "0 MB"
    }

    private func getPurgeablePageCount() -> String {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let purgeablePages = UInt64(vmStats.purgeable_count)
            let pageSize = getPageSize() * 1024
            let purgeableMB = Double(purgeablePages * UInt64(pageSize)) / 1_048_576.0
            return String(format: "%.0f MB (%llu pages)", purgeableMB, purgeablePages)
        }

        return "0 MB"
    }

    private func getCopyOnWriteFaults() -> String {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let cowFaults = UInt64(vmStats.cow_faults)
            if cowFaults > 1_000_000 {
                return String(format: "%.2f M", Double(cowFaults) / 1_000_000.0)
            } else if cowFaults > 1_000 {
                return String(format: "%.1f K", Double(cowFaults) / 1_000.0)
            }
            return "\(cowFaults)"
        }

        return "0"
    }

    // MARK: - Display Helper Functions

    private func getScreenResolution() -> String {
        let screen = UIScreen.main
        let width = Int(screen.nativeBounds.width)
        let height = Int(screen.nativeBounds.height)
        return "\(width) × \(height)"
    }

    private func getScreenSize() -> String {
        let deviceModel = getDeviceModel()

        // iPhone screen sizes
        if deviceModel.contains("iPhone16,2") || deviceModel.contains("iPhone17,1") {
            return "6.7 inches"
        } else if deviceModel.contains("iPhone16,1") || deviceModel.contains("iPhone17,3") {
            return "6.1 inches"
        } else if deviceModel.contains("iPhone15,3") {
            return "6.7 inches"
        } else if deviceModel.contains("iPhone15,2") {
            return "6.1 inches"
        } else if deviceModel.contains("iPad") {
            if deviceModel.contains("iPad14,") || deviceModel.contains("iPad16,") {
                return "12.9 inches"
            } else if deviceModel.contains("iPad13,") {
                return "11 inches"
            }
            return "10.2-12.9 inches"
        }

        return "Unknown"
    }

    private func getPixelsPerInch() -> String {
        let screen = UIScreen.main
        let scale = screen.scale
        let nativeWidth = screen.nativeBounds.width
        let pointWidth = screen.bounds.width

        // Approximate PPI calculation
        let ppi = Int((nativeWidth / pointWidth) * 163.0 / scale)
        return "\(ppi) PPI"
    }

    private func getRefreshRate() -> String {
        if #available(iOS 15.0, *) {
            let screen = UIScreen.main
            let maxFPS = screen.maximumFramesPerSecond
            return "\(maxFPS) Hz"
        }
        return "60 Hz"
    }

    private func getScreenBrightness() -> String {
        let brightness = UIScreen.main.brightness
        return String(format: "%.0f%%", brightness * 100)
    }

    private func supportsHDR() -> String {
        if #available(iOS 11.0, *) {
            return UIScreen.main.traitCollection.displayGamut == .P3 ? "Yes (Display P3)" : "No"
        }
        return "Unknown"
    }

    // MARK: - System/Kernel Helper Functions

    private func getKernelVersion() -> String {
        var size: size_t = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var version = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &version, &size, nil, 0)
        return String(cString: version)
    }

    private func getSystemUptime() -> String {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.size
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]

        sysctl(&mib, 2, &boottime, &size, nil, 0)

        let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
        let uptime = Date().timeIntervalSince(bootDate)

        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let minutes = (Int(uptime) % 3600) / 60

        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func getBootTime() -> String {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.size
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]

        sysctl(&mib, 2, &boottime, &size, nil, 0)

        let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: bootDate)
    }

    private func getSystemArchitecture() -> String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private func getHostname() -> String {
        return ProcessInfo.processInfo.hostName
    }

    private func getTimeZone() -> String {
        let timeZone = TimeZone.current
        return "\(timeZone.identifier) (UTC\(timeZone.secondsFromGMT() >= 0 ? "+" : "")\(timeZone.secondsFromGMT() / 3600))"
    }

    // MARK: - Battery Helper Functions

    private func getBatteryHealth() -> String? {
        // iOS doesn't expose battery health directly
        // This would require private APIs
        return nil
    }

    private func getPowerSource() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState

        switch state {
        case .charging, .full:
            return "AC Power"
        case .unplugged:
            return "Battery"
        default:
            return "Unknown"
        }
    }

    // MARK: - Thermal Helper Functions

    private func getThermalState() -> String {
        let state = ProcessInfo.processInfo.thermalState

        switch state {
        case .nominal:
            return "Normal"
        case .fair:
            return "Fair"
        case .serious:
            return "Serious"
        case .critical:
            return "Critical"
        @unknown default:
            return "Unknown"
        }
    }

    private func getLowPowerMode() -> String {
        return ProcessInfo.processInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled"
    }

    // MARK: - Graphics Helper Functions

    private func getMetalVersion() -> String {
        if let device = MTLCreateSystemDefaultDevice() {
            if #available(iOS 16.0, *) {
                return "Metal 3"
            } else if #available(iOS 14.0, *) {
                return "Metal 2.3"
            } else {
                return "Metal 2"
            }
        }
        return "Not Available"
    }

    private func getGPUFamily() -> String {
        let deviceModel = getDeviceModel()

        if deviceModel.contains("iPhone16") || deviceModel.contains("iPhone17") {
            return "Apple GPU (A18)"
        } else if deviceModel.contains("iPhone15,3") || deviceModel.contains("iPhone15,2") {
            return "Apple GPU (A17 Pro)"
        } else if deviceModel.contains("iPhone15") {
            return "Apple GPU (A16)"
        } else if deviceModel.contains("iPhone14") {
            return "Apple GPU (A15)"
        }

        return "Apple GPU"
    }

    // MARK: - Storage Helper Functions

    private func getFileSystemType() -> String {
        return "APFS (Apple File System)"
    }

    private func getEncryptionStatus() -> String {
        // iOS devices are always encrypted
        return "Encrypted (AES-256)"
    }

    // MARK: - Locale Helper Functions

    private func getCurrentLocale() -> String {
        return Locale.current.identifier
    }

    private func getPreferredLanguages() -> String {
        let languages = Locale.preferredLanguages.prefix(3)
        return languages.joined(separator: ", ")
    }

    private func getRegionFormat() -> String {
        if let regionCode = Locale.current.region?.identifier {
            return regionCode
        }
        return "Unknown"
    }

    private func getCalendarType() -> String {
        let identifier = Locale.current.calendar.identifier
        switch identifier {
        case .gregorian:
            return "Gregorian"
        case .buddhist:
            return "Buddhist"
        case .chinese:
            return "Chinese"
        case .coptic:
            return "Coptic"
        case .ethiopicAmeteMihret:
            return "Ethiopic Amete Mihret"
        case .ethiopicAmeteAlem:
            return "Ethiopic Amete Alem"
        case .hebrew:
            return "Hebrew"
        case .iso8601:
            return "ISO 8601"
        case .indian:
            return "Indian"
        case .islamic:
            return "Islamic"
        case .islamicCivil:
            return "Islamic Civil"
        case .japanese:
            return "Japanese"
        case .persian:
            return "Persian"
        case .republicOfChina:
            return "Republic of China"
        case .islamicTabular:
            return "Islamic Tabular"
        case .islamicUmmAlQura:
            return "Islamic Umm al-Qura"
        @unknown default:
            return "Gregorian"
        }
    }

    private func getMeasurementSystem() -> String {
        let system = Locale.current.measurementSystem
        if system == .metric {
            return "Metric"
        } else if system == .us {
            return "US (Imperial)"
        } else if system == .uk {
            return "UK (Imperial)"
        } else {
            return "Metric"
        }
    }

    // MARK: - Security Helper Functions

    private func hasSecureEnclave() -> String {
        // Check if device supports Secure Enclave
        let deviceModel = getDeviceModel()
        if deviceModel.contains("iPhone") || deviceModel.contains("iPad") {
            return "Available"
        }
        return "Not Available"
    }

    private func getDataProtectionLevel() -> String {
        return "Complete Protection"
    }

    // MARK: - Audio Helper Functions

    private func getSpatialAudioSupport() -> String {
        let deviceModel = getDeviceModel()
        if deviceModel.contains("iPhone12") || deviceModel.contains("iPhone13") ||
           deviceModel.contains("iPhone14") || deviceModel.contains("iPhone15") ||
           deviceModel.contains("iPhone16") || deviceModel.contains("iPhone17") {
            return "Supported"
        }
        return "Not Supported"
    }
}

// MARK: - Sensors View

@available(iOS 17.0, *)
struct SensorsView: View {
    @State private var motionManager = CMMotionManager()
    @State private var hasAccelerometer = false
    @State private var hasGyroscope = false
    @State private var hasMagnetometer = false
    @State private var hasBarometer = false

    var body: some View {
        List {
            // Available Sensors
            Section {
                SensorRow(name: "Accelerometer", available: hasAccelerometer, icon: "Move.3d")
                SensorRow(name: "Gyroscope", available: hasGyroscope, icon: "gyroscope")
                SensorRow(name: "Magnetometer", available: hasMagnetometer, icon: "location.north.fill")
                SensorRow(name: "Barometer", available: hasBarometer, icon: "barometer")
                SensorRow(name: "Proximity Sensor", available: true, icon: "sensor")
                SensorRow(name: "Ambient Light Sensor", available: true, icon: "light.max")
            } header: {
                HStack {
                    Image(systemName: "sensor.fill")
                        .foregroundStyle(.blue.gradient)
                    Text("Available Sensors")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("These sensors provide motion, orientation, and environmental data to apps.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Biometric Authentication
            Section {
                BiometricRow()
            } header: {
                HStack {
                    Image(systemName: "faceid")
                        .foregroundStyle(.green.gradient)
                    Text("Biometric Authentication")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Camera Information
            Section {
                CameraInfoRow()
            } header: {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(.purple.gradient)
                    Text("Camera")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Other Features
            Section {
                FeatureRow(name: "Flashlight", available: hasFlashlight(), icon: "flashlight.on.fill")
                FeatureRow(name: "Vibration (Haptics)", available: true, icon: "iphone.radiowaves.left.and.right")
            } header: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                    Text("Other Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            checkSensorAvailability()
        }
    }

    private func checkSensorAvailability() {
        hasAccelerometer = motionManager.isAccelerometerAvailable
        hasGyroscope = motionManager.isGyroAvailable
        hasMagnetometer = motionManager.isMagnetometerAvailable
        hasBarometer = CMAltimeter.isRelativeAltitudeAvailable()
    }

    private func hasFlashlight() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.hasTorch
    }
}

struct SensorRow: View {
    let name: String
    let available: Bool
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(available ? Color.blue : Color.gray)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)

                Text(available ? "Available" : "Not Available")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(available ? .green : .secondary)
            }

            Spacer()

            if available {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 20))
            }
        }
        .padding(.vertical, 4)
    }
}

struct BiometricRow: View {
    @State private var biometricType: String = "Unknown"

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForBiometric())
                .font(.system(size: 24))
                .foregroundStyle(.green.gradient)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(biometricType)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Biometric authentication method")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 20))
        }
        .padding(.vertical, 4)
        .onAppear {
            detectBiometricType()
        }
    }

    private func detectBiometricType() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = "Face ID"
            case .touchID:
                biometricType = "Touch ID"
            case .opticID:
                if #available(iOS 17.0, *) {
                    biometricType = "Optic ID"
                } else {
                    biometricType = "Biometric Authentication"
                }
            case .none:
                biometricType = "None"
            @unknown default:
                biometricType = "Unknown"
            }
        } else {
            biometricType = "Not Available"
        }
    }

    private func iconForBiometric() -> String {
        switch biometricType {
        case "Face ID":
            return "faceid"
        case "Touch ID":
            return "touchid"
        case "Optic ID":
            return "opticid"
        default:
            return "person.badge.key.fill"
        }
    }
}

struct CameraInfoRow: View {
    @State private var cameraCount = 0
    @State private var hasUltraWide = false
    @State private var hasTelephoto = false
    @State private var hasLiDAR = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.purple.gradient)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(cameraCount) Camera\(cameraCount != 1 ? "s" : "")")
                        .font(.system(size: 16, weight: .medium, design: .rounded))

                    Text("Rear camera system")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 4)

            if hasUltraWide || hasTelephoto || hasLiDAR {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    if hasUltraWide {
                        FeatureTag(name: "Ultra Wide", icon: "camera.metering.matrix")
                    }
                    if hasTelephoto {
                        FeatureTag(name: "Telephoto", icon: "camera.metering.center.weighted.average")
                    }
                    if hasLiDAR {
                        FeatureTag(name: "LiDAR Scanner", icon: "light.beacon.max.fill")
                    }
                }
            }
        }
        .onAppear {
            detectCameraCapabilities()
        }
    }

    private func detectCameraCapabilities() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInLiDARDepthCamera],
            mediaType: .video,
            position: .back
        )

        cameraCount = discoverySession.devices.filter { device in
            device.deviceType == .builtInWideAngleCamera ||
            device.deviceType == .builtInUltraWideCamera ||
            device.deviceType == .builtInTelephotoCamera
        }.count

        hasUltraWide = discoverySession.devices.contains { $0.deviceType == .builtInUltraWideCamera }
        hasTelephoto = discoverySession.devices.contains { $0.deviceType == .builtInTelephotoCamera }
        hasLiDAR = discoverySession.devices.contains { $0.deviceType == .builtInLiDARDepthCamera }
    }
}

struct FeatureRow: View {
    let name: String
    let available: Bool
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(available ? Color.yellow : Color.gray)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)

                Text(available ? "Available" : "Not Available")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(available ? .green : .secondary)
            }

            Spacer()

            if available {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 20))
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeatureTag: View {
    let name: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(name)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .foregroundStyle(.purple)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.purple.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    SettingsView()
        .environment(SettingsManager.shared)
        .environment(MetricsManager.shared)
}
