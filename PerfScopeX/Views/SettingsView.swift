//
//  SettingsView.swift
//  PerfScopeX
//
//  Settings screen for customizing metrics and preferences (iOS 17+ design)
//

import SwiftUI
import CoreMotion
import AVFoundation
import LocalAuthentication
import CoreLocation
import ARKit
import SceneKit
import CoreNFC

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

                    NavigationLink {
                        OSSLicensesView()
                    } label: {
                        HStack {
                            Text("Open Source Licenses")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
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

    // Detail view states
    @State private var showingAccelerometer = false
    @State private var showingGyroscope = false
    @State private var showingMagnetometer = false
    @State private var showingBarometer = false
    @State private var showingProximity = false
    @State private var showingLightSensor = false
    @State private var showingBiometric = false
    @State private var showingFlashlight = false
    @State private var showingHaptics = false
    @State private var showingPedometer = false
    @State private var showingDeviceMotion = false
    @State private var showingLocation = false
    @State private var showingCompass = false
    @State private var showingAudio = false
    @State private var showingCamera = false
    @State private var showingLiDAR = false
    @State private var showingMotionCoprocessor = false
    @State private var showingIBeacon = false
    @State private var showingRegionMonitoring = false
    @State private var showingActivityRecognition = false

    var body: some View {
        List {
            // Available Sensors
            Section {
                Button { showingAccelerometer = true } label: {
                    SensorRow(name: "Accelerometer", available: hasAccelerometer, icon: "Move.3d")
                }
                .disabled(!hasAccelerometer)

                Button { showingGyroscope = true } label: {
                    SensorRow(name: "Gyroscope", available: hasGyroscope, icon: "gyroscope")
                }
                .disabled(!hasGyroscope)

                Button { showingMagnetometer = true } label: {
                    SensorRow(name: "Magnetometer", available: hasMagnetometer, icon: "location.north.fill")
                }
                .disabled(!hasMagnetometer)

                Button { showingBarometer = true } label: {
                    SensorRow(name: "Barometer", available: hasBarometer, icon: "barometer")
                }
                .disabled(!hasBarometer)

                Button { showingProximity = true } label: {
                    SensorRow(name: "Proximity Sensor", available: true, icon: "sensor")
                }

                Button { showingLightSensor = true } label: {
                    SensorRow(name: "Ambient Light Sensor", available: true, icon: "light.max")
                }
            } header: {
                HStack {
                    Image(systemName: "sensor.fill")
                        .foregroundStyle(.blue.gradient)
                    Text("Available Sensors")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap each sensor to test and view live data.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Biometric Authentication
            Section {
                Button { showingBiometric = true } label: {
                    BiometricRow()
                }
            } header: {
                HStack {
                    Image(systemName: "faceid")
                        .foregroundStyle(.green.gradient)
                    Text("Biometric Authentication")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to test biometric authentication.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Camera Information
            Section {
                Button { showingCamera = true } label: {
                    CameraInfoRow()
                }
            } header: {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(.purple.gradient)
                    Text("Camera")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to view live camera preview and test camera features.")
                    .font(.system(size: 12, design: .rounded))
            }

            // LiDAR Scanner
            Section {
                Button { showingLiDAR = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "light.beacon.max.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(hasLiDARScanner() ? Color.purple : Color.gray)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("LiDAR Scanner")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)

                            Text(hasLiDARScanner() ? "Available" : "Not Available")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(hasLiDARScanner() ? .green : .secondary)
                        }

                        Spacer()

                        if hasLiDARScanner() {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .disabled(!hasLiDARScanner())
            } header: {
                HStack {
                    Image(systemName: "light.beacon.max.fill")
                        .foregroundStyle(.purple.gradient)
                    Text("Depth Sensing")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to visualize depth map and measure distances with the LiDAR scanner.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Other Features
            Section {
                Button { showingFlashlight = true } label: {
                    FeatureRow(name: "Flashlight", available: hasFlashlight(), icon: "flashlight.on.fill")
                }
                .disabled(!hasFlashlight())

                Button { showingHaptics = true } label: {
                    FeatureRow(name: "Vibration (Haptics)", available: true, icon: "iphone.radiowaves.left.and.right")
                }
            } header: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                    Text("Other Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to test flashlight and haptic feedback.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Motion & Activity
            Section {
                Button { showingPedometer = true } label: {
                    FeatureRow(name: "Pedometer", available: CMPedometer.isStepCountingAvailable(), icon: "figure.walk")
                }
                .disabled(!CMPedometer.isStepCountingAvailable())

                Button { showingDeviceMotion = true } label: {
                    FeatureRow(name: "Device Motion", available: motionManager.isDeviceMotionAvailable, icon: "move.3d")
                }
                .disabled(!motionManager.isDeviceMotionAvailable)

                Button { showingMotionCoprocessor = true } label: {
                    FeatureRow(name: "Motion Coprocessor", available: hasMotionCoprocessor(), icon: "cpu")
                }
                .disabled(!hasMotionCoprocessor())

                Button { showingActivityRecognition = true } label: {
                    FeatureRow(name: "Activity Recognition", available: CMMotionActivityManager.isActivityAvailable(), icon: "figure.run")
                }
                .disabled(!CMMotionActivityManager.isActivityAvailable())
            } header: {
                HStack {
                    Image(systemName: "figure.walk.motion")
                        .foregroundStyle(.orange.gradient)
                    Text("Motion & Activity")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap Pedometer or Device Motion to view live data.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Location Services
            Section {
                Button { showingLocation = true } label: {
                    FeatureRow(name: "GPS", available: CLLocationManager.locationServicesEnabled(), icon: "location.fill")
                }

                Button { showingCompass = true } label: {
                    FeatureRow(name: "Compass", available: CLLocationManager.headingAvailable(), icon: "location.north.line.fill")
                }

                Button { showingIBeacon = true } label: {
                    FeatureRow(name: "iBeacon", available: CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self), icon: "wave.3.right")
                }
                .disabled(!CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self))

                Button { showingRegionMonitoring = true } label: {
                    FeatureRow(name: "Region Monitoring", available: CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self), icon: "map")
                }
                .disabled(!CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self))
            } header: {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundStyle(.cyan.gradient)
                    Text("Location Services")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap GPS or Compass to view location data.")
                    .font(.system(size: 12, design: .rounded))
            }

            // AR Capabilities
            Section {
                ARCapabilitiesRow()
            } header: {
                HStack {
                    Image(systemName: "arkit")
                        .foregroundStyle(.purple.gradient)
                    Text("AR Capabilities")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Augmented Reality features powered by ARKit and LiDAR scanner.")
                    .font(.system(size: 12, design: .rounded))
            }

            // TrueDepth Camera
            Section {
                TrueDepthRow()
            } header: {
                HStack {
                    Image(systemName: "faceid")
                        .foregroundStyle(.green.gradient)
                    Text("TrueDepth Camera")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Touch & Haptics
            Section {
                TouchHapticsRow()
            } header: {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(.pink.gradient)
                    Text("Touch & Haptics")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Audio Sensors
            Section {
                Button { showingAudio = true } label: {
                    AudioSensorsRow()
                }
            } header: {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(.red.gradient)
                    Text("Audio Sensors")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to view microphone level meter.")
                    .font(.system(size: 12, design: .rounded))
            }

            // Connectivity
            Section {
                ConnectivityRow()
            } header: {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.indigo.gradient)
                    Text("Connectivity")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Battery Features
            Section {
                BatteryFeaturesRow()
            } header: {
                HStack {
                    Image(systemName: "battery.100.bolt")
                        .foregroundStyle(.green.gradient)
                    Text("Battery Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            // Always-On Features
            Section {
                AlwaysOnFeaturesRow()
            } header: {
                HStack {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .foregroundStyle(.teal.gradient)
                    Text("Always-On Features")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            checkSensorAvailability()
        }
        .sheet(isPresented: $showingAccelerometer) {
            AccelerometerDetailView()
        }
        .sheet(isPresented: $showingGyroscope) {
            GyroscopeDetailView()
        }
        .sheet(isPresented: $showingMagnetometer) {
            MagnetometerDetailView()
        }
        .sheet(isPresented: $showingBarometer) {
            BarometerDetailView()
        }
        .sheet(isPresented: $showingProximity) {
            ProximitySensorDetailView()
        }
        .sheet(isPresented: $showingLightSensor) {
            LightSensorDetailView()
        }
        .sheet(isPresented: $showingBiometric) {
            BiometricTestView()
        }
        .sheet(isPresented: $showingFlashlight) {
            FlashlightTestView()
        }
        .sheet(isPresented: $showingHaptics) {
            HapticsTestView()
        }
        .sheet(isPresented: $showingPedometer) {
            PedometerDetailView()
        }
        .sheet(isPresented: $showingDeviceMotion) {
            DeviceMotionDetailView()
        }
        .sheet(isPresented: $showingLocation) {
            GPSLocationDetailView()
        }
        .sheet(isPresented: $showingCompass) {
            CompassDetailView()
        }
        .sheet(isPresented: $showingAudio) {
            AudioMeterDetailView()
        }
        .sheet(isPresented: $showingCamera) {
            CameraTestView()
        }
        .sheet(isPresented: $showingLiDAR) {
            LiDARDepthView()
        }
        .sheet(isPresented: $showingMotionCoprocessor) {
            MotionCoprocessorDetailView()
        }
        .sheet(isPresented: $showingIBeacon) {
            IBeaconDetailView()
        }
        .sheet(isPresented: $showingRegionMonitoring) {
            RegionMonitoringDetailView()
        }
        .sheet(isPresented: $showingActivityRecognition) {
            ActivityRecognitionDetailView()
        }
    }

    private func hasLiDARScanner() -> Bool {
        if #available(iOS 14.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInLiDARDepthCamera],
                mediaType: .video,
                position: .back
            )
            return !discoverySession.devices.isEmpty
        }
        return false
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

    private func hasMotionCoprocessor() -> Bool {
        return CMPedometer.isStepCountingAvailable() || CMMotionActivityManager.isActivityAvailable()
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

struct ARCapabilitiesRow: View {
    @State private var supportsARKit = false
    @State private var supportsWorldTracking = false
    @State private var supportsFaceTracking = false
    @State private var supportsImageTracking = false
    @State private var supportsObjectScanning = false
    @State private var hasLiDARForAR = false
    @State private var supportsPeopleOcclusion = false
    @State private var supportsSceneGeometry = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if #available(iOS 13.0, *) {
                if supportsARKit {
                    VStack(alignment: .leading, spacing: 8) {
                        if supportsWorldTracking {
                            FeatureTag(name: "World Tracking", icon: "cube.transparent")
                        }
                        if supportsFaceTracking {
                            FeatureTag(name: "Face Tracking", icon: "face.smiling")
                        }
                        if supportsImageTracking {
                            FeatureTag(name: "Image Tracking", icon: "photo")
                        }
                        if supportsObjectScanning {
                            FeatureTag(name: "Object Scanning", icon: "cube.box")
                        }
                        if hasLiDARForAR {
                            FeatureTag(name: "LiDAR Scanner", icon: "light.beacon.max.fill")
                        }
                        if supportsPeopleOcclusion {
                            FeatureTag(name: "People Occlusion", icon: "figure.stand")
                        }
                        if supportsSceneGeometry {
                            FeatureTag(name: "Scene Geometry", icon: "square.grid.3x3.square")
                        }
                    }
                } else {
                    Text("ARKit not supported on this device")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            detectARCapabilities()
        }
    }

    private func detectARCapabilities() {
        if #available(iOS 13.0, *) {
            let configuration = ARWorldTrackingConfiguration()
            supportsARKit = ARWorldTrackingConfiguration.isSupported
            supportsWorldTracking = ARWorldTrackingConfiguration.isSupported
            supportsFaceTracking = ARFaceTrackingConfiguration.isSupported
            supportsImageTracking = ARImageTrackingConfiguration.isSupported
            supportsObjectScanning = ARObjectScanningConfiguration.isSupported

            if #available(iOS 13.4, *) {
                hasLiDARForAR = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
            }

            if #available(iOS 13.0, *) {
                supportsPeopleOcclusion = ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)
            }

            if #available(iOS 13.4, *) {
                supportsSceneGeometry = ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification)
            }
        }
    }
}

struct TrueDepthRow: View {
    @State private var hasTrueDepth = false
    @State private var supportsDepthCapture = false
    @State private var supportsAnimoji = false
    @State private var supportsPortraitLighting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasTrueDepth {
                VStack(alignment: .leading, spacing: 8) {
                    FeatureTag(name: "TrueDepth Camera", icon: "camera.metering.multispot")
                    if supportsDepthCapture {
                        FeatureTag(name: "Depth Capture", icon: "camera.aperture")
                    }
                    if supportsAnimoji {
                        FeatureTag(name: "Animoji / Memoji", icon: "face.smiling")
                    }
                    if supportsPortraitLighting {
                        FeatureTag(name: "Portrait Lighting", icon: "light.max")
                    }
                }
            } else {
                Text("TrueDepth camera not available")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            detectTrueDepthCapabilities()
        }
    }

    private func detectTrueDepthCapabilities() {
        // Check for front-facing camera with depth capability
        if let device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
            hasTrueDepth = true
            supportsDepthCapture = device.activeFormat.isPortraitEffectsMatteStillImageDeliverySupported
            supportsAnimoji = ARFaceTrackingConfiguration.isSupported
            supportsPortraitLighting = device.activeFormat.supportedDepthDataFormats.count > 0
        }
    }
}

struct TouchHapticsRow: View {
    @State private var has3DTouch = false
    @State private var hasHapticTouch = true // All modern devices
    @State private var tapticEngineGeneration = "Taptic Engine"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                if has3DTouch {
                    FeatureTag(name: "3D Touch", icon: "hand.point.up.left.fill")
                } else {
                    FeatureTag(name: "Haptic Touch", icon: "hand.tap.fill")
                }
                FeatureTag(name: tapticEngineGeneration, icon: "iphone.radiowaves.left.and.right")
            }
        }
        .onAppear {
            detectTouchHapticsCapabilities()
        }
    }

    private func detectTouchHapticsCapabilities() {
        // 3D Touch was available on iPhone 6s through iPhone XS
        let deviceModel = getDeviceModel()
        if deviceModel.contains("iPhone8,") || deviceModel.contains("iPhone9,") || deviceModel.contains("iPhone10,3") || deviceModel.contains("iPhone10,6") {
            has3DTouch = true
        }

        // Determine Taptic Engine generation
        if deviceModel.contains("iPhone16") || deviceModel.contains("iPhone15") || deviceModel.contains("iPhone14") {
            tapticEngineGeneration = "Taptic Engine (3rd Gen)"
        } else if deviceModel.contains("iPhone13") || deviceModel.contains("iPhone12") || deviceModel.contains("iPhone11") {
            tapticEngineGeneration = "Taptic Engine (2nd Gen)"
        } else {
            tapticEngineGeneration = "Taptic Engine"
        }
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return modelCode
    }
}

struct AudioSensorsRow: View {
    @State private var microphoneCount = 0
    @State private var hasSpatialAudioRecording = false
    @State private var hasNoiseCancellation = true // Most modern devices
    @State private var hasAudioZoom = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                FeatureTag(name: "\(microphoneCount) Microphone\(microphoneCount != 1 ? "s" : "")", icon: "mic.fill")
                if hasSpatialAudioRecording {
                    FeatureTag(name: "Spatial Audio Recording", icon: "mic.badge.plus")
                }
                if hasNoiseCancellation {
                    FeatureTag(name: "Noise Cancellation", icon: "waveform.badge.minus")
                }
                if hasAudioZoom {
                    FeatureTag(name: "Audio Zoom", icon: "waveform.badge.magnifyingglass")
                }
            }
        }
        .onAppear {
            detectAudioCapabilities()
        }
    }

    private func detectAudioCapabilities() {
        // Count microphones
        let audioSession = AVAudioSession.sharedInstance()
        let inputs = audioSession.currentRoute.inputs
        microphoneCount = inputs.filter { $0.portType == .builtInMic }.first?.channels?.count ?? 3

        // Spatial audio recording typically on Pro models
        let deviceModel = getDeviceModel()
        if deviceModel.contains("iPhone15,2") || deviceModel.contains("iPhone15,3") ||
           deviceModel.contains("iPhone16,1") || deviceModel.contains("iPhone16,2") {
            hasSpatialAudioRecording = true
        }

        // Audio zoom available on devices with multiple mics
        hasAudioZoom = microphoneCount >= 2
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return modelCode
    }
}

struct ConnectivityRow: View {
    @State private var hasNFC = false
    @State private var hasUWB = false
    @State private var bluetoothVersion = "5.0"
    @State private var wifiVersion = "Wi-Fi 6"
    @State private var has5G = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                if hasNFC {
                    FeatureTag(name: "NFC", icon: "wave.3.right")
                }
                if hasUWB {
                    FeatureTag(name: "Ultra Wideband (U1/U2)", icon: "point.3.connected.trianglepath.dotted")
                }
                FeatureTag(name: "Bluetooth \(bluetoothVersion)", icon: "bluetooth")
                FeatureTag(name: wifiVersion, icon: "wifi")
                if has5G {
                    FeatureTag(name: "5G", icon: "antenna.radiowaves.left.and.right")
                }
            }
        }
        .onAppear {
            detectConnectivityCapabilities()
        }
    }

    private func detectConnectivityCapabilities() {
        let deviceModel = getDeviceModel()

        // NFC available on iPhone 7 and later
        if !deviceModel.contains("iPhone8,") && !deviceModel.contains("iPhone7,") && !deviceModel.contains("iPhone6,") {
            hasNFC = NFCReaderSession.readingAvailable
        }

        // UWB (U1 chip) available on iPhone 11 and later
        if deviceModel.contains("iPhone12") || deviceModel.contains("iPhone13") ||
           deviceModel.contains("iPhone14") || deviceModel.contains("iPhone15") || deviceModel.contains("iPhone16") {
            hasUWB = true
        }

        // Determine Bluetooth version
        if deviceModel.contains("iPhone16") || deviceModel.contains("iPhone15") {
            bluetoothVersion = "5.3"
        } else if deviceModel.contains("iPhone14") || deviceModel.contains("iPhone13") {
            bluetoothVersion = "5.0"
        } else {
            bluetoothVersion = "5.0"
        }

        // Determine WiFi version
        if deviceModel.contains("iPhone16") {
            wifiVersion = "Wi-Fi 7"
        } else if deviceModel.contains("iPhone15") || deviceModel.contains("iPhone14") || deviceModel.contains("iPhone13") {
            wifiVersion = "Wi-Fi 6E"
        } else {
            wifiVersion = "Wi-Fi 6"
        }

        // 5G available on iPhone 12 and later
        if deviceModel.contains("iPhone13") || deviceModel.contains("iPhone14") ||
           deviceModel.contains("iPhone15") || deviceModel.contains("iPhone16") || deviceModel.contains("iPhone12") {
            has5G = true
        }
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return modelCode
    }
}

struct BatteryFeaturesRow: View {
    @State private var supportsWirelessCharging = false
    @State private var supportsMagSafe = false
    @State private var supportsFastCharging = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                if supportsWirelessCharging {
                    FeatureTag(name: "Wireless Charging (Qi)", icon: "battery.100.bolt")
                }
                if supportsMagSafe {
                    FeatureTag(name: "MagSafe", icon: "circle.grid.cross.fill")
                }
                if supportsFastCharging {
                    FeatureTag(name: "Fast Charging", icon: "bolt.fill")
                }
            }
        }
        .onAppear {
            detectBatteryFeatures()
        }
    }

    private func detectBatteryFeatures() {
        let deviceModel = getDeviceModel()

        // Wireless charging available on iPhone 8 and later
        if !deviceModel.contains("iPhone8,") && !deviceModel.contains("iPhone7,") && !deviceModel.contains("iPhone6,") {
            supportsWirelessCharging = true
        }

        // MagSafe available on iPhone 12 and later
        if deviceModel.contains("iPhone13") || deviceModel.contains("iPhone14") ||
           deviceModel.contains("iPhone15") || deviceModel.contains("iPhone16") || deviceModel.contains("iPhone12") {
            supportsMagSafe = true
        }

        // Fast charging available on iPhone 8 and later
        supportsFastCharging = true
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return modelCode
    }
}

struct AlwaysOnFeaturesRow: View {
    @State private var supportsAlwaysOnDisplay = false
    @State private var hasAlwaysOnProcessor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if supportsAlwaysOnDisplay || hasAlwaysOnProcessor {
                VStack(alignment: .leading, spacing: 8) {
                    if supportsAlwaysOnDisplay {
                        FeatureTag(name: "Always-On Display", icon: "clock.badge.checkmark")
                    }
                    if hasAlwaysOnProcessor {
                        FeatureTag(name: "Always-On Processor", icon: "cpu")
                    }
                }
            } else {
                Text("Always-On features not available")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            detectAlwaysOnFeatures()
        }
    }

    private func detectAlwaysOnFeatures() {
        let deviceModel = getDeviceModel()

        // Always-On Display available on iPhone 14 Pro and later Pro models
        if deviceModel.contains("iPhone15,2") || deviceModel.contains("iPhone15,3") ||
           deviceModel.contains("iPhone16,1") || deviceModel.contains("iPhone16,2") {
            supportsAlwaysOnDisplay = true
            hasAlwaysOnProcessor = true
        }
    }

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return modelCode
    }
}

// MARK: - Sensor Detail Views

struct AccelerometerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var motionManager: CMMotionManager?
    @State private var x: Double = 0
    @State private var y: Double = 0
    @State private var z: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "move.3d")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Accelerometer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    SensorDataRow(label: "X-Axis", value: x, color: .red)
                    SensorDataRow(label: "Y-Axis", value: y, color: .green)
                    SensorDataRow(label: "Z-Axis", value: z, color: .blue)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Tilt and move your device to see real-time acceleration data.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startAccelerometer()
            }
            .onDisappear {
                stopAccelerometer()
            }
        }
    }

    private func startAccelerometer() {
        let manager = CMMotionManager()
        motionManager = manager
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.1
            manager.startAccelerometerUpdates(to: .main) { [self] data, error in
                guard let data = data else { return }
                x = data.acceleration.x
                y = data.acceleration.y
                z = data.acceleration.z
            }
        }
    }

    private func stopAccelerometer() {
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
    }
}

struct GyroscopeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var motionManager: CMMotionManager?
    @State private var x: Double = 0
    @State private var y: Double = 0
    @State private var z: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "gyroscope")
                    .font(.system(size: 80))
                    .foregroundStyle(.purple.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Gyroscope")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    SensorDataRow(label: "X-Rotation", value: x, color: .red, unit: "rad/s")
                    SensorDataRow(label: "Y-Rotation", value: y, color: .green, unit: "rad/s")
                    SensorDataRow(label: "Z-Rotation", value: z, color: .blue, unit: "rad/s")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Rotate your device to see real-time gyroscope data.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startGyroscope()
            }
            .onDisappear {
                stopGyroscope()
            }
        }
    }

    private func startGyroscope() {
        let manager = CMMotionManager()
        motionManager = manager
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = 0.1
            manager.startGyroUpdates(to: .main) { [self] data, error in
                guard let data = data else { return }
                x = data.rotationRate.x
                y = data.rotationRate.y
                z = data.rotationRate.z
            }
        }
    }

    private func stopGyroscope() {
        motionManager?.stopGyroUpdates()
        motionManager = nil
    }
}

struct MagnetometerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var motionManager: CMMotionManager?
    @State private var x: Double = 0
    @State private var y: Double = 0
    @State private var z: Double = 0
    @State private var heading: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green.gradient)
                    .symbolRenderingMode(.hierarchical)
                    .rotationEffect(.degrees(heading))

                Text("Magnetometer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    SensorDataRow(label: "X-Field", value: x, color: .red, unit: "μT")
                    SensorDataRow(label: "Y-Field", value: y, color: .green, unit: "μT")
                    SensorDataRow(label: "Z-Field", value: z, color: .blue, unit: "μT")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Move your device to see magnetic field strength.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startMagnetometer()
            }
            .onDisappear {
                stopMagnetometer()
            }
        }
    }

    private func startMagnetometer() {
        let manager = CMMotionManager()
        motionManager = manager
        if manager.isMagnetometerAvailable {
            manager.magnetometerUpdateInterval = 0.1
            manager.startMagnetometerUpdates(to: .main) { [self] data, error in
                guard let data = data else { return }
                x = data.magneticField.x
                y = data.magneticField.y
                z = data.magneticField.z
                heading = atan2(y, x) * 180 / .pi
            }
        }
    }

    private func stopMagnetometer() {
        motionManager?.stopMagnetometerUpdates()
        motionManager = nil
    }
}

struct BarometerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var altimeter: CMAltimeter?
    @State private var pressure: Double = 0
    @State private var altitude: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "barometer")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Barometer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Pressure")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f kPa", pressure))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }

                    Divider()

                    VStack(spacing: 8) {
                        Text("Relative Altitude")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f m", altitude))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Move up or down stairs/elevators to see altitude changes.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startBarometer()
            }
            .onDisappear {
                stopBarometer()
            }
        }
    }

    private func startBarometer() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            let newAltimeter = CMAltimeter()
            altimeter = newAltimeter
            newAltimeter.startRelativeAltitudeUpdates(to: .main) { [self] data, error in
                guard let data = data else { return }
                pressure = data.pressure.doubleValue
                altitude = data.relativeAltitude.doubleValue
            }
        }
    }

    private func stopBarometer() {
        altimeter?.stopRelativeAltitudeUpdates()
        altimeter = nil
    }
}

struct ProximitySensorDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isNear = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: isNear ? "sensor.fill" : "sensor")
                    .font(.system(size: 80))
                    .foregroundStyle(isNear ? Color.red.gradient : Color.gray.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Proximity Sensor")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    Text(isNear ? "Object Detected" : "No Object")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(isNear ? .red : .gray)

                    Text(isNear ? "Something is close to the sensor" : "Nothing is near the sensor")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Cover the top of your device near the front camera to activate the proximity sensor.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                UIDevice.current.isProximityMonitoringEnabled = true
                NotificationCenter.default.addObserver(forName: UIDevice.proximityStateDidChangeNotification, object: nil, queue: .main) { _ in
                    isNear = UIDevice.current.proximityState
                }
            }
            .onDisappear {
                UIDevice.current.isProximityMonitoringEnabled = false
            }
        }
    }
}

struct LightSensorDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var brightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "light.max")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow.gradient)
                    .symbolRenderingMode(.hierarchical)
                    .opacity(Double(brightness))

                Text("Ambient Light Sensor")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    Text("Screen Brightness")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text("\(Int(brightness * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.yellow)

                    ProgressView(value: brightness, total: 1.0)
                        .tint(.yellow)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("The ambient light sensor adjusts your screen brightness automatically. Current screen brightness is shown above.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startMonitoring()
            }
        }
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            brightness = UIScreen.main.brightness
        }
    }
}

struct BiometricTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authenticationStatus = "Not tested"
    @State private var statusColor: Color = .gray
    @State private var isAuthenticating = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "faceid")
                    .font(.system(size: 80))
                    .foregroundStyle(statusColor.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Biometric Test")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    Text(authenticationStatus)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(statusColor)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    authenticateUser()
                } label: {
                    Label("Test Authentication", systemImage: "checkmark.shield.fill")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isAuthenticating)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func authenticateUser() {
        isAuthenticating = true
        authenticationStatus = "Authenticating..."
        statusColor = .blue

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Test biometric authentication"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    isAuthenticating = false
                    if success {
                        authenticationStatus = "Authentication Successful"
                        statusColor = .green
                    } else {
                        authenticationStatus = "Authentication Failed"
                        statusColor = .red
                    }
                }
            }
        } else {
            isAuthenticating = false
            authenticationStatus = "Biometric authentication not available"
            statusColor = .orange
        }
    }
}

struct FlashlightTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isFlashlightOn = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(isFlashlightOn ? Color.yellow.gradient : Color.gray.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Flashlight Test")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    Text(isFlashlightOn ? "Flashlight is ON" : "Flashlight is OFF")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(isFlashlightOn ? .yellow : .gray)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    toggleFlashlight()
                } label: {
                    Label(isFlashlightOn ? "Turn Off" : "Turn On", systemImage: isFlashlightOn ? "flashlight.off.fill" : "flashlight.on.fill")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFlashlightOn ? Color.red.gradient : Color.yellow.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if isFlashlightOn {
                            toggleFlashlight()
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isFlashlightOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
            isFlashlightOn.toggle()
        } catch {
            print("Flashlight error: \(error)")
        }
    }
}

struct HapticsTestView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Haptic Feedback Test")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Tap the buttons to feel different haptic feedbacks")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    HapticButton(title: "Light Impact", style: .light)
                    HapticButton(title: "Medium Impact", style: .medium)
                    HapticButton(title: "Heavy Impact", style: .heavy)
                    HapticButton(title: "Soft Impact", style: .soft)
                    HapticButton(title: "Rigid Impact", style: .rigid)
                }

                Divider()

                VStack(spacing: 12) {
                    NotificationHapticButton(title: "Success", type: .success)
                    NotificationHapticButton(title: "Warning", type: .warning)
                    NotificationHapticButton(title: "Error", type: .error)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HapticButton: View {
    let title: String
    let style: UIImpactFeedbackGenerator.FeedbackStyle

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct NotificationHapticButton: View {
    let title: String
    let type: UINotificationFeedbackGenerator.FeedbackType

    var body: some View {
        Button {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PedometerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pedometer: CMPedometer?
    @State private var stepCount: Int = 0
    @State private var distance: Double = 0
    @State private var floorsAscended: Int = 0
    @State private var floorsDescended: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Pedometer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Steps")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(stepCount)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }

                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Text("Distance")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f m", distance))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.blue)
                        }

                        Divider().frame(height: 40)

                        VStack(spacing: 8) {
                            Text("Floors ↑")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(floorsAscended)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }

                        Divider().frame(height: 40)

                        VStack(spacing: 8) {
                            Text("Floors ↓")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(floorsDescended)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Walk around to track your steps and movement.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startPedometer()
            }
            .onDisappear {
                stopPedometer()
            }
        }
    }

    private func startPedometer() {
        if CMPedometer.isStepCountingAvailable() {
            let newPedometer = CMPedometer()
            pedometer = newPedometer
            newPedometer.startUpdates(from: Date()) { [self] data, error in
                guard let data = data else { return }
                stepCount = data.numberOfSteps.intValue
                distance = data.distance?.doubleValue ?? 0
                floorsAscended = data.floorsAscended?.intValue ?? 0
                floorsDescended = data.floorsDescended?.intValue ?? 0
            }
        }
    }

    private func stopPedometer() {
        pedometer?.stopUpdates()
        pedometer = nil
    }
}

struct DeviceMotionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var motionManager: CMMotionManager?
    @State private var pitch: Double = 0
    @State private var roll: Double = 0
    @State private var yaw: Double = 0
    @State private var gravityX: Double = 0
    @State private var gravityY: Double = 0
    @State private var gravityZ: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "move.3d")
                    .font(.system(size: 80))
                    .foregroundStyle(.purple.gradient)
                    .symbolRenderingMode(.hierarchical)
                    .rotation3DEffect(.degrees(pitch * 30), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(roll * 30), axis: (x: 0, y: 0, z: 1))

                Text("Device Motion")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    Text("Attitude")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    SensorDataRow(label: "Pitch", value: pitch, color: .red, unit: "rad")
                    SensorDataRow(label: "Roll", value: roll, color: .green, unit: "rad")
                    SensorDataRow(label: "Yaw", value: yaw, color: .blue, unit: "rad")

                    Divider()

                    Text("Gravity")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    SensorDataRow(label: "X-Gravity", value: gravityX, color: .red, unit: "g")
                    SensorDataRow(label: "Y-Gravity", value: gravityY, color: .green, unit: "g")
                    SensorDataRow(label: "Z-Gravity", value: gravityZ, color: .blue, unit: "g")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Tilt and rotate your device to see attitude and gravity data.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                startDeviceMotion()
            }
            .onDisappear {
                stopDeviceMotion()
            }
        }
    }

    private func startDeviceMotion() {
        let manager = CMMotionManager()
        motionManager = manager
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdates(to: .main) { [self] data, error in
                guard let data = data else { return }
                pitch = data.attitude.pitch
                roll = data.attitude.roll
                yaw = data.attitude.yaw
                gravityX = data.gravity.x
                gravityY = data.gravity.y
                gravityZ = data.gravity.z
            }
        }
    }

    private func stopDeviceMotion() {
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
    }
}

struct MotionCoprocessorDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var activityManager = MotionActivityManagerHelper()
    @StateObject private var pedometerManager = PedometerManagerHelper()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Icon
                    Image(systemName: "cpu")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange.gradient)
                        .symbolRenderingMode(.hierarchical)

                    Text("Motion Coprocessor")
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    // Coprocessor Model
                    VStack(spacing: 12) {
                        Text("Chip Model")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)

                        Text(getMotionCoprocessorModel())
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Current Activity
                    if CMMotionActivityManager.isActivityAvailable() {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: getActivityIcon(activityManager.currentActivity))
                                    .font(.system(size: 40))
                                    .foregroundStyle(getActivityColor(activityManager.currentActivity))
                                    .symbolRenderingMode(.hierarchical)
                                    .frame(width: 60)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Activity")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)

                                    Text(activityManager.currentActivity)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    if activityManager.confidence != "Unknown" {
                                        Text("Confidence: \(activityManager.confidence)")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Pedometer Data
                    if CMPedometer.isStepCountingAvailable() {
                        VStack(spacing: 16) {
                            Text("Today's Activity")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            HStack(spacing: 20) {
                                // Steps
                                VStack(spacing: 8) {
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.blue)

                                    Text("\(pedometerManager.steps)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("Steps")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)

                                Divider().frame(height: 60)

                                // Distance
                                VStack(spacing: 8) {
                                    Image(systemName: "map")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.green)

                                    Text(String(format: "%.2f", pedometerManager.distance / 1000))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("Kilometers")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }

                            Divider()

                            HStack(spacing: 20) {
                                // Floors Up
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.orange)

                                    Text("\(pedometerManager.floorsAscended)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("Floors Up")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)

                                Divider().frame(height: 60)

                                // Floors Down
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.purple)

                                    Text("\(pedometerManager.floorsDescended)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("Floors Down")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }

                            if pedometerManager.currentPace > 0 {
                                Divider()

                                VStack(spacing: 8) {
                                    Image(systemName: "speedometer")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.cyan)

                                    Text(String(format: "%.1f", pedometerManager.currentPace * 60))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text("Steps/Minute")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.blue)
                            Text("About Motion Coprocessor")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }

                        Text("The motion coprocessor continuously monitors motion data from the accelerometer, gyroscope, compass, and barometer without draining battery. It enables features like step counting, activity recognition, and fitness tracking.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                activityManager.startMonitoring()
                pedometerManager.startMonitoring()
            }
            .onDisappear {
                activityManager.stopMonitoring()
                pedometerManager.stopMonitoring()
            }
        }
    }

    private func getMotionCoprocessorModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        // Map device models to motion coprocessor models
        if identifier.contains("iPhone17") { return "M16" }
        if identifier.contains("iPhone16") { return "M16" }
        if identifier.contains("iPhone15") { return "M15" }
        if identifier.contains("iPhone14") { return "M14" }
        if identifier.contains("iPhone13") { return "M13" }
        if identifier.contains("iPhone12") { return "M12" }
        if identifier.contains("iPhone11") { return "M11" }
        if identifier.contains("iPhone10") { return "M10" }
        if identifier.contains("iPhone9") { return "M10" }
        if identifier.contains("iPhone8") { return "M9" }
        if identifier.contains("iPhone7") { return "M8" }
        if identifier.contains("iPhone6") { return "M7" }

        return "M-Series"
    }

    private func getActivityIcon(_ activity: String) -> String {
        switch activity {
        case "Stationary": return "figure.stand"
        case "Walking": return "figure.walk"
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Automotive": return "car.fill"
        default: return "questionmark.circle"
        }
    }

    private func getActivityColor(_ activity: String) -> Color {
        switch activity {
        case "Stationary": return .gray
        case "Walking": return .blue
        case "Running": return .orange
        case "Cycling": return .green
        case "Automotive": return .red
        default: return .secondary
        }
    }
}

// MARK: - Motion Activity Manager Helper

class MotionActivityManagerHelper: ObservableObject {
    @Published var currentActivity: String = "Unknown"
    @Published var confidence: String = "Unknown"

    private let activityManager = CMMotionActivityManager()

    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            currentActivity = "Not Available"
            return
        }

        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }

            if activity.stationary {
                self?.currentActivity = "Stationary"
            } else if activity.walking {
                self?.currentActivity = "Walking"
            } else if activity.running {
                self?.currentActivity = "Running"
            } else if activity.cycling {
                self?.currentActivity = "Cycling"
            } else if activity.automotive {
                self?.currentActivity = "Automotive"
            } else {
                self?.currentActivity = "Unknown"
            }

            switch activity.confidence {
            case .low:
                self?.confidence = "Low"
            case .medium:
                self?.confidence = "Medium"
            case .high:
                self?.confidence = "High"
            @unknown default:
                self?.confidence = "Unknown"
            }
        }
    }

    func stopMonitoring() {
        activityManager.stopActivityUpdates()
    }
}

// MARK: - Pedometer Manager Helper

class PedometerManagerHelper: ObservableObject {
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0
    @Published var floorsAscended: Int = 0
    @Published var floorsDescended: Int = 0
    @Published var currentPace: Double = 0.0

    private let pedometer = CMPedometer()

    func startMonitoring() {
        guard CMPedometer.isStepCountingAvailable() else { return }

        // Get today's data
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }

        pedometer.queryPedometerData(from: startOfDay, to: now) { [weak self] data, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                self?.steps = data.numberOfSteps.intValue
                self?.distance = data.distance?.doubleValue ?? 0.0
                self?.floorsAscended = data.floorsAscended?.intValue ?? 0
                self?.floorsDescended = data.floorsDescended?.intValue ?? 0
            }
        }

        // Start live updates
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                if let pace = data.currentPace {
                    self?.currentPace = pace.doubleValue
                }
            }
        }
    }

    func stopMonitoring() {
        pedometer.stopUpdates()
    }
}

struct GPSLocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManagerHelper()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "location.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.cyan.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("GPS Location")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                if let location = locationManager.location {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Coordinates")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.6f°, %.6f°", location.coordinate.latitude, location.coordinate.longitude))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundStyle(.cyan)
                        }

                        Divider()

                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                Text("Altitude")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.1f m", location.altitude))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.blue)
                            }

                            Divider().frame(height: 40)

                            VStack(spacing: 8) {
                                Text("Speed")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.1f m/s", max(0, location.speed)))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.green)
                            }
                        }

                        Divider()

                        VStack(spacing: 8) {
                            Text("Accuracy")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(String(format: "±%.0f m", location.horizontalAccuracy))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text(locationManager.authorizationStatus)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                Text("Location data updates in real-time as you move.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                locationManager.startUpdating()
            }
            .onDisappear {
                locationManager.stopUpdating()
            }
        }
    }
}

class LocationManagerHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus = "Requesting permission..."

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startUpdating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationStatus = "Location authorized"
        case .denied:
            authorizationStatus = "Location access denied"
        case .restricted:
            authorizationStatus = "Location access restricted"
        case .notDetermined:
            authorizationStatus = "Waiting for permission..."
        @unknown default:
            authorizationStatus = "Unknown status"
        }
    }
}

struct CompassDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var compassManager = CompassManagerHelper()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(.cyan.opacity(0.3))
                        .frame(width: 200, height: 200)

                    Image(systemName: "location.north.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.cyan.gradient)
                        .symbolRenderingMode(.hierarchical)
                        .rotationEffect(.degrees(-compassManager.heading))

                    VStack {
                        Text("N")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                            .offset(y: -110)
                    }
                    .rotationEffect(.degrees(-compassManager.heading))
                }
                .padding()

                Text("Compass")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Heading")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f°", compassManager.heading))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.cyan)
                    }

                    Text(compassManager.direction)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    if compassManager.accuracy > 0 {
                        Text(String(format: "Accuracy: ±%.0f°", compassManager.accuracy))
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Rotate your device to see the compass heading change.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                compassManager.startUpdating()
            }
            .onDisappear {
                compassManager.stopUpdating()
            }
        }
    }
}

class CompassManagerHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var heading: Double = 0
    @Published var accuracy: Double = 0
    @Published var direction: String = "—"

    override init() {
        super.init()
        manager.delegate = self
        manager.headingFilter = 1
    }

    func startUpdating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingHeading()
    }

    func stopUpdating() {
        manager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
        accuracy = newHeading.headingAccuracy
        direction = getDirection(from: heading)
    }

    private func getDirection(from degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }
}

struct IBeaconDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var beaconManager = BeaconManagerHelper()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scanning Indicator
                if beaconManager.isScanning {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.blue)

                        Text("Scanning for iBeacons...")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding()
                    .background(.blue.opacity(0.1))
                }

                // Beacons List
                List {
                    if beaconManager.detectedBeacons.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "wave.3.right.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                                .symbolRenderingMode(.hierarchical)

                            Text("No iBeacons Detected")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)

                            Text("Make sure iBeacons are nearby and broadcasting.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            if !beaconManager.isScanning {
                                Button {
                                    beaconManager.startScanning()
                                } label: {
                                    Label("Start Scanning", systemImage: "play.fill")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(beaconManager.detectedBeacons) { beacon in
                                BeaconRow(beacon: beacon)
                            }
                        } header: {
                            HStack {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                    .foregroundStyle(.blue)
                                Text("Detected Beacons (\(beaconManager.detectedBeacons.count))")
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                    }

                    // Info Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("About iBeacon")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }

                            Text("iBeacon is Apple's implementation of Bluetooth Low Energy (BLE) proximity sensing. Each beacon broadcasts a unique identifier consisting of UUID, Major, and Minor values.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                InfoItem(title: "Immediate", description: "Within a few centimeters", color: .green)
                                InfoItem(title: "Near", description: "Within a couple of meters", color: .blue)
                                InfoItem(title: "Far", description: "More than 10 meters away", color: .orange)
                                InfoItem(title: "Unknown", description: "Distance cannot be determined", color: .gray)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.cyan)
                            Text("Proximity Ranges")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("iBeacon Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if beaconManager.isScanning {
                            beaconManager.stopScanning()
                        } else {
                            beaconManager.startScanning()
                        }
                    } label: {
                        Label(
                            beaconManager.isScanning ? "Stop" : "Scan",
                            systemImage: beaconManager.isScanning ? "stop.circle.fill" : "play.circle.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(beaconManager.isScanning ? .red : .green)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                beaconManager.startScanning()
            }
            .onDisappear {
                beaconManager.stopScanning()
            }
        }
    }
}

struct BeaconRow: View {
    let beacon: DetectedBeacon

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(proximityColor(beacon.proximity))
                    .frame(width: 12, height: 12)

                Text(proximityText(beacon.proximity))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(proximityColor(beacon.proximity))

                Spacer()

                if beacon.accuracy >= 0 {
                    Text(String(format: "~%.1fm", beacon.accuracy))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("UUID:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)

                    Text(beacon.uuid)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                HStack {
                    Text("Major:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)

                    Text("\(beacon.major)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.primary)
                }

                HStack {
                    Text("Minor:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)

                    Text("\(beacon.minor)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.primary)
                }

                HStack {
                    Text("RSSI:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)

                    Text("\(beacon.rssi) dBm")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.leading, 20)
        }
        .padding(.vertical, 4)
    }

    private func proximityText(_ proximity: String) -> String {
        switch proximity {
        case "immediate": return "Immediate"
        case "near": return "Near"
        case "far": return "Far"
        default: return "Unknown"
        }
    }

    private func proximityColor(_ proximity: String) -> Color {
        switch proximity {
        case "immediate": return .green
        case "near": return .blue
        case "far": return .orange
        default: return .gray
        }
    }
}

struct InfoItem: View {
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Beacon Manager Helper

struct DetectedBeacon: Identifiable {
    let id = UUID()
    let uuid: String
    let major: Int
    let minor: Int
    let proximity: String
    let accuracy: Double
    let rssi: Int
    let timestamp: Date
}

class BeaconManagerHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var detectedBeacons: [DetectedBeacon] = []
    @Published var isScanning = false

    private let locationManager = CLLocationManager()
    private var beaconRegions: [CLBeaconRegion] = []

    override init() {
        super.init()
        locationManager.delegate = self
        setupBeaconRegions()
    }

    private func setupBeaconRegions() {
        // Common iBeacon UUIDs for testing
        // You can add more UUIDs here for specific beacon manufacturers
        let commonUUIDs = [
            "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", // Apple AirLocate
            "FDA50693-A4E2-4FB1-AFCF-C6EB07647825", // Estimote
            "B9407F30-F5F8-466E-AFF9-25556B57FE6D", // Kontakt.io
            "F7826DA6-4FA2-4E98-8024-BC5B71E0893E", // Radius Networks
            "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"  // Generic
        ]

        for uuidString in commonUUIDs {
            if let uuid = UUID(uuidString: uuidString) {
                if #available(iOS 13.0, *) {
                    let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid)
                    let region = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: uuidString)
                    beaconRegions.append(region)
                } else {
                    let region = CLBeaconRegion(proximityUUID: uuid, identifier: uuidString)
                    beaconRegions.append(region)
                }
            }
        }
    }

    func startScanning() {
        locationManager.requestWhenInUseAuthorization()

        isScanning = true
        detectedBeacons.removeAll()

        for region in beaconRegions {
            locationManager.startMonitoring(for: region)
            if #available(iOS 13.0, *) {
                locationManager.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
            } else {
                locationManager.startRangingBeacons(in: region)
            }
        }
    }

    func stopScanning() {
        isScanning = false

        for region in beaconRegions {
            locationManager.stopMonitoring(for: region)
            if #available(iOS 13.0, *) {
                locationManager.stopRangingBeacons(satisfying: region.beaconIdentityConstraint)
            } else {
                locationManager.stopRangingBeacons(in: region)
            }
        }

        detectedBeacons.removeAll()
    }

    // iOS 13+
    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        updateBeacons(beacons)
    }

    // iOS 12 and earlier
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        updateBeacons(beacons)
    }

    private func updateBeacons(_ beacons: [CLBeacon]) {
        DispatchQueue.main.async {
            // Clear existing beacons
            self.detectedBeacons.removeAll()

            // Add new beacons
            for beacon in beacons {
                let proximityString: String
                switch beacon.proximity {
                case .immediate:
                    proximityString = "immediate"
                case .near:
                    proximityString = "near"
                case .far:
                    proximityString = "far"
                default:
                    proximityString = "unknown"
                }

                let detectedBeacon = DetectedBeacon(
                    uuid: beacon.uuid.uuidString,
                    major: beacon.major.intValue,
                    minor: beacon.minor.intValue,
                    proximity: proximityString,
                    accuracy: beacon.accuracy,
                    rssi: beacon.rssi,
                    timestamp: Date()
                )

                self.detectedBeacons.append(detectedBeacon)
            }

            // Sort by proximity and accuracy
            self.detectedBeacons.sort { beacon1, beacon2 in
                let proximityOrder = ["immediate": 0, "near": 1, "far": 2, "unknown": 3]
                let order1 = proximityOrder[beacon1.proximity] ?? 4
                let order2 = proximityOrder[beacon2.proximity] ?? 4

                if order1 == order2 {
                    return beacon1.accuracy < beacon2.accuracy
                }
                return order1 < order2
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}

struct RegionMonitoringDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var regionManager = RegionMonitoringManagerHelper()
    @State private var showingAddRegion = false
    @State private var newRegionName = ""
    @State private var newRegionLatitude = ""
    @State private var newRegionLongitude = ""
    @State private var newRegionRadius = "100"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Current Location Bar
                if let location = regionManager.currentLocation {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 16))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Location")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            Text(String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Button {
                            regionManager.requestLocation()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .tint(.blue)
                    }
                    .padding()
                    .background(.blue.opacity(0.1))
                }

                // Regions List
                List {
                    if regionManager.monitoredRegions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "map.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                                .symbolRenderingMode(.hierarchical)

                            Text("No Regions Monitored")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)

                            Text("Add a region to start monitoring. You'll be notified when entering or exiting the region.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Button {
                                showingAddRegion = true
                            } label: {
                                Label("Add Region", systemImage: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(regionManager.monitoredRegions) { region in
                                RegionRow(
                                    region: region,
                                    isInside: regionManager.regionStates[region.id] ?? false,
                                    onDelete: {
                                        regionManager.removeRegion(region)
                                    }
                                )
                            }
                        } header: {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundStyle(.green)
                                Text("Monitored Regions (\(regionManager.monitoredRegions.count))")
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                    }

                    // Events Log
                    if !regionManager.events.isEmpty {
                        Section {
                            ForEach(regionManager.events.prefix(10)) { event in
                                EventRow(event: event)
                            }
                        } header: {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(.orange)
                                Text("Recent Events")
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                    }

                    // Info Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("About Region Monitoring")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }

                            Text("Region monitoring allows your device to detect when you enter or exit a defined geographic area. Each region is defined by a center coordinate (latitude/longitude) and a radius.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                InfoItem(title: "Max Radius", description: "Up to 400 meters", color: .blue)
                                InfoItem(title: "System Limit", description: "Max 20 regions per app", color: .orange)
                                InfoItem(title: "Battery Impact", description: "Low - uses geofencing", color: .green)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.cyan)
                            Text("Information")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Region Monitoring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAddRegion = true
                    } label: {
                        Label("Add Region", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.green)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddRegion) {
                AddRegionView(
                    name: $newRegionName,
                    latitude: $newRegionLatitude,
                    longitude: $newRegionLongitude,
                    radius: $newRegionRadius,
                    currentLocation: regionManager.currentLocation,
                    onAdd: { name, lat, lon, radius in
                        regionManager.addRegion(
                            name: name,
                            latitude: lat,
                            longitude: lon,
                            radius: radius
                        )
                        showingAddRegion = false
                        newRegionName = ""
                        newRegionLatitude = ""
                        newRegionLongitude = ""
                        newRegionRadius = "100"
                    }
                )
            }
            .onAppear {
                regionManager.startMonitoring()
            }
            .onDisappear {
                regionManager.stopMonitoring()
            }
        }
    }
}

struct RegionRow: View {
    let region: MonitoredRegion
    let isInside: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isInside ? Color.green : Color.gray)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(region.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.blue)
                        Text(String(format: "%.6f, %.6f", region.latitude, region.longitude))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "circle.dotted")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Text("\(Int(region.radius))m")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(isInside ? Color.green : Color.gray)
                        .frame(width: 6, height: 6)
                    Text(isInside ? "Inside Region" : "Outside Region")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(isInside ? .green : .secondary)
                }
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .tint(.red)
        }
        .padding(.vertical, 4)
    }
}

struct EventRow: View {
    let event: RegionEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type == "enter" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(event.type == "enter" ? .green : .orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.type == "enter" ? "Entered" : "Exited")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(event.regionName)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddRegionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var radius: String
    let currentLocation: CLLocation?
    let onAdd: (String, Double, Double, Double) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Region Name", text: $name)
                        .font(.system(size: 16, design: .rounded))
                } header: {
                    Text("Name")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                Section {
                    if let location = currentLocation {
                        Button {
                            latitude = String(format: "%.6f", location.coordinate.latitude)
                            longitude = String(format: "%.6f", location.coordinate.longitude)
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.blue)
                                Text("Use Current Location")
                                    .font(.system(size: 15, design: .rounded))
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 15, design: .monospaced))

                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 15, design: .monospaced))
                } header: {
                    Text("Coordinates")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Valid range: Latitude (-90 to 90), Longitude (-180 to 180)")
                        .font(.system(size: 11, design: .rounded))
                }

                Section {
                    HStack {
                        TextField("Radius", text: $radius)
                            .keyboardType(.numberPad)
                            .font(.system(size: 15, design: .monospaced))
                        Text("meters")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Radius")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Recommended: 100-400 meters. Smaller regions may drain battery faster.")
                        .font(.system(size: 11, design: .rounded))
                }
            }
            .navigationTitle("Add Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let lat = Double(latitude),
                              let lon = Double(longitude),
                              let rad = Double(radius),
                              !name.isEmpty else { return }

                        onAdd(name, lat, lon, rad)
                    }
                    .disabled(name.isEmpty || latitude.isEmpty || longitude.isEmpty || radius.isEmpty)
                }
            }
        }
    }
}

// MARK: - Region Monitoring Manager Helper

struct MonitoredRegion: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    let identifier: String
}

struct RegionEvent: Identifiable {
    let id = UUID()
    let regionName: String
    let type: String // "enter" or "exit"
    let timestamp: Date
}

class RegionMonitoringManagerHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var monitoredRegions: [MonitoredRegion] = []
    @Published var regionStates: [UUID: Bool] = [:]
    @Published var events: [RegionEvent] = []
    @Published var currentLocation: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        for region in monitoredRegions {
            if let clRegion = createCLRegion(from: region) {
                locationManager.stopMonitoring(for: clRegion)
            }
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func addRegion(name: String, latitude: Double, longitude: Double, radius: Double) {
        let identifier = UUID().uuidString
        let region = MonitoredRegion(
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: min(radius, 400), // Cap at 400m
            identifier: identifier
        )

        monitoredRegions.append(region)
        regionStates[region.id] = false

        if let clRegion = createCLRegion(from: region) {
            locationManager.startMonitoring(for: clRegion)
            locationManager.requestState(for: clRegion)
        }
    }

    func removeRegion(_ region: MonitoredRegion) {
        if let clRegion = createCLRegion(from: region) {
            locationManager.stopMonitoring(for: clRegion)
        }

        monitoredRegions.removeAll { $0.id == region.id }
        regionStates.removeValue(forKey: region.id)
    }

    private func createCLRegion(from region: MonitoredRegion) -> CLCircularRegion? {
        let center = CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude)
        let clRegion = CLCircularRegion(center: center, radius: region.radius, identifier: region.identifier)
        clRegion.notifyOnEntry = true
        clRegion.notifyOnExit = true
        return clRegion
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let clRegion = region as? CLCircularRegion,
              let monitoredRegion = monitoredRegions.first(where: { $0.identifier == clRegion.identifier }) else { return }

        DispatchQueue.main.async {
            self.regionStates[monitoredRegion.id] = true
            self.events.insert(RegionEvent(
                regionName: monitoredRegion.name,
                type: "enter",
                timestamp: Date()
            ), at: 0)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let clRegion = region as? CLCircularRegion,
              let monitoredRegion = monitoredRegions.first(where: { $0.identifier == clRegion.identifier }) else { return }

        DispatchQueue.main.async {
            self.regionStates[monitoredRegion.id] = false
            self.events.insert(RegionEvent(
                regionName: monitoredRegion.name,
                type: "exit",
                timestamp: Date()
            ), at: 0)
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let clRegion = region as? CLCircularRegion,
              let monitoredRegion = monitoredRegions.first(where: { $0.identifier == clRegion.identifier }) else { return }

        DispatchQueue.main.async {
            self.regionStates[monitoredRegion.id] = (state == .inside)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}

struct ActivityRecognitionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var activityRecognition = ActivityRecognitionManagerHelper()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Activity Card
                    VStack(spacing: 20) {
                        Image(systemName: getActivityIcon(activityRecognition.currentActivity))
                            .font(.system(size: 100))
                            .foregroundStyle(getActivityColor(activityRecognition.currentActivity))
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffect(.bounce, value: activityRecognition.currentActivity)

                        VStack(spacing: 8) {
                            Text("Current Activity")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            Text(activityRecognition.currentActivity)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            // Confidence Badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(getConfidenceColor(activityRecognition.confidence))
                                    .frame(width: 8, height: 8)

                                Text("Confidence: \(activityRecognition.confidence)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )

                    // Activity Statistics
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(.blue)
                            Text("Today's Activity Breakdown")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                        }

                        if !activityRecognition.activityDurations.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(activityRecognition.activityDurations.sorted(by: { $0.value > $1.value }), id: \.key) { activity, duration in
                                    ActivityDurationRow(
                                        activity: activity,
                                        duration: duration,
                                        totalDuration: activityRecognition.totalDuration
                                    )
                                }
                            }
                        } else {
                            Text("No activity data recorded yet today.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Activity History
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.orange)
                            Text("Recent Activity Changes")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                        }

                        if !activityRecognition.activityHistory.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(activityRecognition.activityHistory.prefix(10)) { record in
                                    ActivityHistoryRow(record: record)
                                }
                            }
                        } else {
                            Text("No activity changes recorded yet.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.blue)
                            Text("About Activity Recognition")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }

                        Text("Activity Recognition uses the motion coprocessor to detect your current activity. It can distinguish between stationary, walking, running, cycling, and automotive activities with varying levels of confidence.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            InfoItem(title: "Low Power", description: "Uses motion coprocessor for efficiency", color: .green)
                            InfoItem(title: "Automatic", description: "Detects activities in the background", color: .blue)
                            InfoItem(title: "Privacy", description: "All processing happens on device", color: .purple)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding()
            }
            .navigationTitle("Activity Recognition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                activityRecognition.startMonitoring()
            }
            .onDisappear {
                activityRecognition.stopMonitoring()
            }
        }
    }

    private func getActivityIcon(_ activity: String) -> String {
        switch activity {
        case "Stationary": return "figure.stand"
        case "Walking": return "figure.walk"
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Automotive": return "car.fill"
        default: return "questionmark.circle"
        }
    }

    private func getActivityColor(_ activity: String) -> Color {
        switch activity {
        case "Stationary": return .gray
        case "Walking": return .blue
        case "Running": return .orange
        case "Cycling": return .green
        case "Automotive": return .red
        default: return .secondary
        }
    }

    private func getConfidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "High": return .green
        case "Medium": return .orange
        case "Low": return .red
        default: return .gray
        }
    }
}

struct ActivityDurationRow: View {
    let activity: String
    let duration: TimeInterval
    let totalDuration: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: getActivityIcon(activity))
                    .font(.system(size: 16))
                    .foregroundStyle(getActivityColor(activity))
                    .frame(width: 24)

                Text(activity)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                Text(formatDuration(duration))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 6)

                    Capsule()
                        .fill(getActivityColor(activity))
                        .frame(width: geometry.size.width * CGFloat(duration / max(totalDuration, 1)), height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func getActivityIcon(_ activity: String) -> String {
        switch activity {
        case "Stationary": return "figure.stand"
        case "Walking": return "figure.walk"
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Automotive": return "car.fill"
        default: return "questionmark.circle"
        }
    }

    private func getActivityColor(_ activity: String) -> Color {
        switch activity {
        case "Stationary": return .gray
        case "Walking": return .blue
        case "Running": return .orange
        case "Cycling": return .green
        case "Automotive": return .red
        default: return .secondary
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

struct ActivityHistoryRow: View {
    let record: ActivityHistoryRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: getActivityIcon(record.activity))
                .font(.system(size: 20))
                .foregroundStyle(getActivityColor(record.activity))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.activity)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(getConfidenceColor(record.confidence))
                        .frame(width: 6, height: 6)

                    Text(record.confidence)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(record.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func getActivityIcon(_ activity: String) -> String {
        switch activity {
        case "Stationary": return "figure.stand"
        case "Walking": return "figure.walk"
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Automotive": return "car.fill"
        default: return "questionmark.circle"
        }
    }

    private func getActivityColor(_ activity: String) -> Color {
        switch activity {
        case "Stationary": return .gray
        case "Walking": return .blue
        case "Running": return .orange
        case "Cycling": return .green
        case "Automotive": return .red
        default: return .secondary
        }
    }

    private func getConfidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "High": return .green
        case "Medium": return .orange
        case "Low": return .red
        default: return .gray
        }
    }
}

// MARK: - Activity Recognition Manager Helper

struct ActivityHistoryRecord: Identifiable {
    let id = UUID()
    let activity: String
    let confidence: String
    let timestamp: Date
}

class ActivityRecognitionManagerHelper: ObservableObject {
    @Published var currentActivity: String = "Unknown"
    @Published var confidence: String = "Unknown"
    @Published var activityHistory: [ActivityHistoryRecord] = []
    @Published var activityDurations: [String: TimeInterval] = [:]

    private let activityManager = CMMotionActivityManager()
    private var lastActivityChangeTime: Date?
    private var lastActivity: String?
    private var sessionStartTime: Date?

    var totalDuration: TimeInterval {
        return activityDurations.values.reduce(0, +)
    }

    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            currentActivity = "Not Available"
            return
        }

        sessionStartTime = Date()
        lastActivityChangeTime = Date()

        // Start real-time updates
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            self?.processActivity(activity)
        }

        // Query historical data for today
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }

        activityManager.queryActivityStarting(from: startOfDay, to: now, to: .main) { [weak self] activities, error in
            guard let activities = activities, error == nil else { return }

            // Calculate durations from historical data
            for i in 0..<activities.count {
                let activity = activities[i]
                let activityType = self?.getActivityType(from: activity) ?? "Unknown"

                let endTime: Date
                if i < activities.count - 1 {
                    endTime = activities[i + 1].startDate
                } else {
                    endTime = now
                }

                let duration = endTime.timeIntervalSince(activity.startDate)
                self?.activityDurations[activityType, default: 0] += duration
            }
        }
    }

    func stopMonitoring() {
        // Record final activity duration
        if let lastActivity = lastActivity,
           let lastChangeTime = lastActivityChangeTime {
            let duration = Date().timeIntervalSince(lastChangeTime)
            activityDurations[lastActivity, default: 0] += duration
        }

        activityManager.stopActivityUpdates()
    }

    private func processActivity(_ activity: CMMotionActivity) {
        let activityType = getActivityType(from: activity)
        let confidenceLevel = getConfidenceLevel(from: activity)

        // Update duration if activity changed
        if let lastActivity = lastActivity,
           let lastChangeTime = lastActivityChangeTime,
           lastActivity != activityType {
            let duration = Date().timeIntervalSince(lastChangeTime)
            activityDurations[lastActivity, default: 0] += duration
            lastActivityChangeTime = Date()
        } else if lastActivity == nil {
            lastActivityChangeTime = Date()
        }

        // Update current activity
        if currentActivity != activityType || confidence != confidenceLevel {
            currentActivity = activityType
            confidence = confidenceLevel
            lastActivity = activityType

            // Add to history
            activityHistory.insert(ActivityHistoryRecord(
                activity: activityType,
                confidence: confidenceLevel,
                timestamp: Date()
            ), at: 0)

            // Keep only last 50 records
            if activityHistory.count > 50 {
                activityHistory.removeLast()
            }
        }
    }

    private func getActivityType(from activity: CMMotionActivity) -> String {
        if activity.stationary {
            return "Stationary"
        } else if activity.walking {
            return "Walking"
        } else if activity.running {
            return "Running"
        } else if activity.cycling {
            return "Cycling"
        } else if activity.automotive {
            return "Automotive"
        } else {
            return "Unknown"
        }
    }

    private func getConfidenceLevel(from activity: CMMotionActivity) -> String {
        switch activity.confidence {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        @unknown default:
            return "Unknown"
        }
    }
}

struct AudioMeterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManagerHelper()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "waveform")
                    .font(.system(size: 80))
                    .foregroundStyle(.red.gradient)
                    .symbolRenderingMode(.hierarchical)

                Text("Audio Level Meter")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Input Level")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.gray.opacity(0.2))

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .yellow, .orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(audioManager.level))
                            }
                        }
                        .frame(height: 40)

                        Text(String(format: "%.0f dB", audioManager.decibels))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    if audioManager.isRecording {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 12, height: 12)
                            Text("Monitoring")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Speak or make sounds to see the audio level meter respond.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                audioManager.startMonitoring()
            }
            .onDisappear {
                audioManager.stopMonitoring()
            }
        }
    }
}

class AudioManagerHelper: NSObject, ObservableObject {
    @Published var level: Double = 0
    @Published var decibels: Double = -160
    @Published var isRecording = false

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    func startMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true)

            let url = URL(fileURLWithPath: "/dev/null")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true

            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.updateMeters()
            }
        } catch {
            print("Audio error: \(error)")
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false)
    }

    private func updateMeters() {
        audioRecorder?.updateMeters()
        if let recorder = audioRecorder {
            let db = recorder.averagePower(forChannel: 0)
            decibels = Double(db)
            // Normalize to 0-1 range (assuming -160 to 0 dB range)
            level = max(0, min(1, (Double(db) + 160) / 160))
        }
    }
}

struct CameraTestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManagerHelper()

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()

                // Overlay Controls
                VStack {
                    // Top Bar - Camera Info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cameraManager.currentCameraName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)

                            if let resolution = cameraManager.resolution {
                                Text(resolution)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .shadow(radius: 2)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Spacer()

                        // Flash Toggle
                        if cameraManager.hasFlash {
                            Button {
                                cameraManager.toggleFlash()
                            } label: {
                                Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(cameraManager.isFlashOn ? .yellow : .white)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    // Bottom Controls
                    VStack(spacing: 16) {
                        // Zoom Level
                        if cameraManager.maxZoom > 1 {
                            VStack(spacing: 8) {
                                Text(String(format: "%.1fx", cameraManager.currentZoom))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)

                                HStack(spacing: 12) {
                                    Button {
                                        cameraManager.setZoom(1.0)
                                    } label: {
                                        Text("1x")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundStyle(cameraManager.currentZoom == 1.0 ? .black : .white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(cameraManager.currentZoom == 1.0 ? .white : .clear)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(.white, lineWidth: 1))
                                    }

                                    if cameraManager.maxZoom >= 2 {
                                        Button {
                                            cameraManager.setZoom(2.0)
                                        } label: {
                                            Text("2x")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundStyle(cameraManager.currentZoom == 2.0 ? .black : .white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(cameraManager.currentZoom == 2.0 ? .white : .clear)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(.white, lineWidth: 1))
                                        }
                                    }

                                    if cameraManager.maxZoom >= 5 {
                                        Button {
                                            cameraManager.setZoom(5.0)
                                        } label: {
                                            Text("5x")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundStyle(cameraManager.currentZoom == 5.0 ? .black : .white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(cameraManager.currentZoom == 5.0 ? .white : .clear)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(.white, lineWidth: 1))
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Camera Capabilities
                        HStack(spacing: 12) {
                            if cameraManager.hasUltraWide {
                                CameraCapabilityBadge(name: "Ultra Wide", icon: "camera.metering.matrix", color: .cyan)
                            }
                            if cameraManager.hasTelephoto {
                                CameraCapabilityBadge(name: "Telephoto", icon: "camera.metering.center.weighted", color: .orange)
                            }
                            if cameraManager.hasLiDAR {
                                CameraCapabilityBadge(name: "LiDAR", icon: "light.beacon.max.fill", color: .purple)
                            }
                        }

                        // Switch Camera Button
                        HStack(spacing: 20) {
                            Button {
                                cameraManager.switchCamera()
                            } label: {
                                Label("Switch", systemImage: "arrow.triangle.2.circlepath.camera.fill")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        cameraManager.stopSession()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                cameraManager.startSession()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
        }
    }
}

struct CameraCapabilityBadge: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.8))
        .clipShape(Capsule())
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = context.coordinator.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

class CameraManagerHelper: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var currentCameraName = "Camera"
    @Published var resolution: String?
    @Published var hasFlash = false
    @Published var isFlashOn = false
    @Published var currentZoom: CGFloat = 1.0
    @Published var maxZoom: CGFloat = 1.0
    @Published var hasUltraWide = false
    @Published var hasTelephoto = false
    @Published var hasLiDAR = false

    private var currentCamera: AVCaptureDevice?
    private var currentInput: AVCaptureDeviceInput?
    private var isUsingFrontCamera = false

    override init() {
        super.init()
        detectCameraCapabilities()
    }

    func startSession() {
        guard !session.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupCamera()
            self?.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    private func setupCamera() {
        session.beginConfiguration()

        // Remove existing inputs
        session.inputs.forEach { session.removeInput($0) }

        // Get camera
        let camera = isUsingFrontCamera ?
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) :
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        guard let device = camera,
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
            currentCamera = device

            DispatchQueue.main.async {
                self.updateCameraInfo(device)
            }
        }

        session.commitConfiguration()
    }

    private func updateCameraInfo(_ device: AVCaptureDevice) {
        currentCameraName = isUsingFrontCamera ? "Front Camera" : "Back Camera"

        let format = device.activeFormat
        let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        resolution = "\(dimensions.width) × \(dimensions.height)"

        hasFlash = device.hasTorch
        maxZoom = min(device.activeFormat.videoMaxZoomFactor, 10.0)
        currentZoom = device.videoZoomFactor
    }

    private func detectCameraCapabilities() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInLiDARDepthCamera],
            mediaType: .video,
            position: .back
        )

        hasUltraWide = discoverySession.devices.contains { $0.deviceType == .builtInUltraWideCamera }
        hasTelephoto = discoverySession.devices.contains { $0.deviceType == .builtInTelephotoCamera }
        hasLiDAR = discoverySession.devices.contains { $0.deviceType == .builtInLiDARDepthCamera }
    }

    func switchCamera() {
        isUsingFrontCamera.toggle()
        setupCamera()
    }

    func toggleFlash() {
        guard let device = currentCamera, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isFlashOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
            isFlashOn.toggle()
        } catch {
            print("Flash error: \(error)")
        }
    }

    func setZoom(_ zoom: CGFloat) {
        guard let device = currentCamera else { return }

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = min(max(zoom, 1.0), maxZoom)
            currentZoom = device.videoZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Zoom error: \(error)")
        }
    }
}

struct SensorDataRow: View {
    let label: String
    let value: Double
    let color: Color
    var unit: String = "g"

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer()

            Text(String(format: "%.3f", value))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(color)

            Text(unit)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - LiDAR Depth View

struct LiDARDepthView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var lidarManager = LiDARManagerHelper()
    @State private var selectedPoint: CGPoint?
    @State private var selectedDistance: Float?

    var body: some View {
        NavigationStack {
            ZStack {
                // AR View with Depth Visualization
                LiDARARView(manager: lidarManager, selectedPoint: $selectedPoint, selectedDistance: $selectedDistance)
                    .ignoresSafeArea()

                // Overlay UI
                VStack {
                    // Top Info Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "light.beacon.max.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.purple)
                                Text("LiDAR Depth Sensing")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }

                            if let distance = selectedDistance {
                                HStack(spacing: 8) {
                                    Image(systemName: "ruler")
                                        .font(.system(size: 14))
                                    Text(String(format: "Distance: %.2f m", distance))
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(.white)
                            } else {
                                Text("Tap to measure distance")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Spacer()
                    }
                    .padding()

                    Spacer()

                    // Bottom Legend
                    VStack(spacing: 12) {
                        // Depth Legend
                        VStack(spacing: 12) {
                            Text("Depth Legend")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)

                            HStack(spacing: 0) {
                                ForEach(0..<10) { i in
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    depthColor(for: Float(i) / 10.0),
                                                    depthColor(for: Float(i + 1) / 10.0)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(height: 30)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 8, height: 8)
                                        Text("Close")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    }
                                    Text("0m")
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.7))
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Text("Far")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 8, height: 8)
                                    }
                                    Text("5m+")
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )

                        // Instructions
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.cyan)
                                Text("Tap anywhere to measure distance")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .shadow(radius: 2)

                            Divider()
                                .background(.white.opacity(0.3))

                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.blue)
                                Text(lidarManager.statusMessage)
                                    .font(.system(size: 13, design: .rounded))
                            }
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        lidarManager.stopSession()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onDisappear {
                lidarManager.stopSession()
            }
        }
    }

    private func depthColor(for normalizedDepth: Float) -> Color {
        // Heat map: Red (close) -> Orange -> Yellow -> Green -> Cyan -> Blue (far)
        let depth = Double(normalizedDepth)

        if depth < 0.2 {
            // Red to Orange (0.0 - 0.2)
            let hue = depth * 0.5 // 0.0 (red) to 0.1 (orange)
            return Color(hue: hue, saturation: 1.0, brightness: 1.0)
        } else if depth < 0.4 {
            // Orange to Yellow (0.2 - 0.4)
            let hue = 0.1 + (depth - 0.2) * 0.5 // 0.1 (orange) to 0.16 (yellow)
            return Color(hue: hue, saturation: 1.0, brightness: 1.0)
        } else if depth < 0.6 {
            // Yellow to Green (0.4 - 0.6)
            let hue = 0.16 + (depth - 0.4) * 1.0 // 0.16 (yellow) to 0.36 (green)
            return Color(hue: hue, saturation: 0.9, brightness: 0.95)
        } else if depth < 0.8 {
            // Green to Cyan (0.6 - 0.8)
            let hue = 0.36 + (depth - 0.6) * 1.2 // 0.36 (green) to 0.5 (cyan)
            return Color(hue: hue, saturation: 0.85, brightness: 0.9)
        } else {
            // Cyan to Blue (0.8 - 1.0)
            let hue = 0.5 + (depth - 0.8) * 1.0 // 0.5 (cyan) to 0.66 (blue)
            return Color(hue: hue, saturation: 0.9, brightness: 0.85)
        }
    }
}

struct LiDARARView: UIViewRepresentable {
    let manager: LiDARManagerHelper
    @Binding var selectedPoint: CGPoint?
    @Binding var selectedDistance: Float?

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView

        // Create depth overlay image view
        let depthOverlayView = UIImageView()
        depthOverlayView.contentMode = .scaleAspectFill
        depthOverlayView.alpha = 0.6
        context.coordinator.depthOverlayView = depthOverlayView

        // Add views to container
        containerView.addSubview(arView)
        containerView.addSubview(depthOverlayView)

        arView.translatesAutoresizingMaskIntoConstraints = false
        depthOverlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: containerView.topAnchor),
            arView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            depthOverlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            depthOverlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            depthOverlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            depthOverlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Start AR session
        manager.startSession(with: arView.session)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        containerView.addGestureRecognizer(tapGesture)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager, selectedPoint: $selectedPoint, selectedDistance: $selectedDistance)
    }

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        let manager: LiDARManagerHelper
        var arView: ARSCNView?
        var depthOverlayView: UIImageView?
        @Binding var selectedPoint: CGPoint?
        @Binding var selectedDistance: Float?
        private var frameCount = 0
        private let frameSkip = 3 // Process every 3rd frame to reduce load
        private var isProcessing = false

        init(manager: LiDARManagerHelper, selectedPoint: Binding<CGPoint?>, selectedDistance: Binding<Float?>) {
            self.manager = manager
            self._selectedPoint = selectedPoint
            self._selectedDistance = selectedDistance
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)

            // Perform hit test
            let hitResults = arView.hitTest(location, types: .featurePoint)
            if let hit = hitResults.first {
                let distance = Float(hit.distance)
                DispatchQueue.main.async {
                    self.selectedPoint = location
                    self.selectedDistance = distance
                }
            }
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Skip frames to reduce processing load
            frameCount += 1
            guard frameCount % frameSkip == 0 else { return }

            // Don't process if already processing
            guard !isProcessing else { return }

            // Process depth data
            guard let depthData = frame.sceneDepth?.depthMap else { return }

            isProcessing = true

            // Process on background queue to avoid blocking AR session
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                autoreleasepool {
                    guard let self = self else { return }

                    // Create heat map image from depth data
                    if let heatMapImage = self.createHeatMapImage(from: depthData) {
                        DispatchQueue.main.async {
                            self.depthOverlayView?.image = heatMapImage
                            self.isProcessing = false
                        }
                    } else {
                        self.isProcessing = false
                    }
                }
            }

            manager.processDepthData(depthData)
        }

        private func createHeatMapImage(from depthMap: CVPixelBuffer) -> UIImage? {
            guard CVPixelBufferLockBaseAddress(depthMap, .readOnly) == kCVReturnSuccess else {
                return nil
            }
            defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

            let fullWidth = CVPixelBufferGetWidth(depthMap)
            let fullHeight = CVPixelBufferGetHeight(depthMap)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)

            guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else { return nil }
            let depthData = baseAddress.assumingMemoryBound(to: Float32.self)

            // Downsample to reduce processing (use 1/4 resolution)
            let downsample = 4
            let width = fullWidth / downsample
            let height = fullHeight / downsample

            guard width > 0, height > 0 else { return nil }

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return nil }

            guard let pixelBuffer = context.data?.assumingMemoryBound(to: UInt8.self) else { return nil }

            let depthStride = bytesPerRow / MemoryLayout<Float32>.size

            // Use fixed depth range instead of scanning entire buffer
            let minDepth: Float = 0.0
            let maxDepth: Float = 5.0

            // Create colored image with downsampling
            for y in 0..<height {
                for x in 0..<width {
                    let srcX = x * downsample
                    let srcY = y * downsample
                    let depthIndex = srcY * depthStride + srcX
                    let depth = depthData[depthIndex]

                    let pixelIndex = (y * width + x) * 4

                    if depth > 0 && depth.isFinite && depth <= maxDepth {
                        // Normalize depth to 0-1 range
                        let normalizedDepth = min(max((depth - minDepth) / (maxDepth - minDepth), 0), 1)
                        let color = getDepthColor(for: normalizedDepth)

                        pixelBuffer[pixelIndex] = UInt8(color.red * 255)
                        pixelBuffer[pixelIndex + 1] = UInt8(color.green * 255)
                        pixelBuffer[pixelIndex + 2] = UInt8(color.blue * 255)
                        pixelBuffer[pixelIndex + 3] = 255
                    } else {
                        // Transparent for invalid depth
                        pixelBuffer[pixelIndex] = 0
                        pixelBuffer[pixelIndex + 1] = 0
                        pixelBuffer[pixelIndex + 2] = 0
                        pixelBuffer[pixelIndex + 3] = 0
                    }
                }
            }

            guard let cgImage = context.makeImage() else { return nil }
            return UIImage(cgImage: cgImage)
        }

        private func getDepthColor(for normalizedDepth: Float) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
            let depth = CGFloat(normalizedDepth)

            if depth < 0.2 {
                // Red to Orange
                let t = depth / 0.2
                return (1.0, t * 0.5, 0.0)
            } else if depth < 0.4 {
                // Orange to Yellow
                let t = (depth - 0.2) / 0.2
                return (1.0, 0.5 + t * 0.5, 0.0)
            } else if depth < 0.6 {
                // Yellow to Green
                let t = (depth - 0.4) / 0.2
                return (1.0 - t, 1.0, 0.0)
            } else if depth < 0.8 {
                // Green to Cyan
                let t = (depth - 0.6) / 0.2
                return (0.0, 1.0, t)
            } else {
                // Cyan to Blue
                let t = (depth - 0.8) / 0.2
                return (0.0, 1.0 - t * 0.5, 1.0)
            }
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            DispatchQueue.main.async {
                self.manager.statusMessage = "AR Session failed: \(error.localizedDescription)"
            }
        }

        func sessionWasInterrupted(_ session: ARSession) {
            DispatchQueue.main.async {
                self.manager.statusMessage = "AR Session interrupted"
            }
        }

        func sessionInterruptionEnded(_ session: ARSession) {
            DispatchQueue.main.async {
                self.manager.statusMessage = "LiDAR active - Scanning environment"
            }
        }
    }
}

class LiDARManagerHelper: NSObject, ObservableObject {
    private var arSession: ARSession?
    @Published var statusMessage = "Initializing LiDAR..."
    private var isSessionRunning = false

    func startSession(with session: ARSession) {
        guard !isSessionRunning else { return }
        arSession = session

        if #available(iOS 14.0, *) {
            let configuration = ARWorldTrackingConfiguration()

            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
                configuration.frameSemantics.insert(.sceneDepth)

                DispatchQueue.main.async {
                    self.statusMessage = "LiDAR active - Scanning environment"
                }

                session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                isSessionRunning = true
            } else {
                DispatchQueue.main.async {
                    self.statusMessage = "LiDAR not available on this device"
                }
            }
        } else {
            DispatchQueue.main.async {
                self.statusMessage = "Requires iOS 14.0 or later"
            }
        }
    }

    func stopSession() {
        guard isSessionRunning else { return }
        arSession?.pause()
        isSessionRunning = false
    }

    func processDepthData(_ depthMap: CVPixelBuffer) {
        // Process depth map data
        // This can be used for visualization
    }
}

// MARK: - OSS Licenses View

struct OSSLicensesView: View {
    var body: some View {
        List {
            Section {
                Text("Activity Monitor uses the following Apple frameworks and technologies to provide comprehensive device monitoring and sensor testing capabilities.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Section {
                OSSLicenseRow(
                    name: "SwiftUI",
                    description: "Apple's declarative framework for building user interfaces across all Apple platforms.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "AVFoundation",
                    description: "Framework for working with audiovisual media, including camera capture, audio recording, and playback.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "CoreMotion",
                    description: "Framework for accessing motion and environmental sensor data, including accelerometer, gyroscope, magnetometer, and barometer.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "CoreLocation",
                    description: "Framework for determining device location and heading information using GPS and compass.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "LocalAuthentication",
                    description: "Framework for authenticating users via Face ID, Touch ID, or Optic ID.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "ARKit",
                    description: "Framework for creating augmented reality experiences with device motion tracking and scene understanding.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "CoreNFC",
                    description: "Framework for reading Near Field Communication (NFC) tags.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "WidgetKit",
                    description: "Framework for creating home screen widgets and Live Activities.",
                    version: "iOS 17.0+",
                    license: "Apple Software License"
                )

                OSSLicenseRow(
                    name: "ActivityKit",
                    description: "Framework for displaying Live Activities on the Lock Screen and Dynamic Island.",
                    version: "iOS 16.1+",
                    license: "Apple Software License"
                )
            } header: {
                Text("Apple Frameworks")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Apple Software License Agreement")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    Text("All Apple frameworks and technologies are used under the Apple Software License Agreement. For the complete license terms, please visit:")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)

                    Link("developer.apple.com/terms", destination: URL(string: "https://developer.apple.com/terms/")!)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .padding(.vertical, 8)
            } header: {
                Text("License Information")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "swift")
                            .font(.system(size: 20))
                            .foregroundStyle(.orange)
                        Text("Built with Swift")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }

                    Text("This application is written entirely in Swift, Apple's powerful and intuitive programming language.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label("Modern", systemImage: "sparkles")
                        Label("Safe", systemImage: "lock.shield")
                        Label("Fast", systemImage: "hare")
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.blue)
                }
                .padding(.vertical, 8)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("© 2025 Activity Monitor")
                        .font(.system(size: 14, weight: .medium, design: .rounded))

                    Text("All rights reserved. This application and its source code are provided for monitoring device sensors and system metrics.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Copyright")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
        }
        .navigationTitle("Open Source Licenses")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct OSSLicenseRow: View {
    let name: String
    let description: String
    let version: String
    let license: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Text(version)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.gradient)
                    .clipShape(Capsule())
            }

            Text(description)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "doc.text")
                    .font(.system(size: 11))
                Text(license)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    SettingsView()
        .environment(SettingsManager.shared)
        .environment(MetricsManager.shared)
}
