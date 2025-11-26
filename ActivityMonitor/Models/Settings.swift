//
//  Settings.swift
//  ActivityMonitor
//
//  User settings and preferences (iOS 17+)
//

import Foundation
import Observation
import WidgetKit

enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case auto = "Auto"
}

struct AppSettings: Codable {
    var enabledMetrics: Set<MetricType>
    var refreshInterval: TimeInterval // In seconds
    var historyDuration: TimeInterval // How long to keep data
    var maxDataPoints: Int
    var showDetailedCPU: Bool // Show User/System breakdown instead of total
    var showDetailedMemory: Bool // Show Active/Inactive/Wired/Compressed breakdown instead of total
    var showDetailedNetwork: Bool // Show Download/Upload breakdown instead of total
    var showDetailedDiskIO: Bool // Show Read/Write breakdown instead of total
    var widgetMetric1: MetricType // First metric to show in widget
    var widgetMetric2: MetricType // Second metric to show in widget
    var pipMetric: MetricType // Metric to show in Picture-in-Picture
    var appTheme: AppTheme // App theme (light or dark)
    var hapticsEnabled: Bool // Enable/disable haptic feedback

    static let `default` = AppSettings(
        enabledMetrics: [
            .cpuTotal,
            .memoryTotal,
            .networkTotal,
            .storage,
            .battery,
            .diskIOTotal
        ],
        refreshInterval: 1.0,
        historyDuration: 300.0, // 5 minutes
        maxDataPoints: 300,
        showDetailedCPU: false, // Default to total view
        showDetailedMemory: false, // Default to total view
        showDetailedNetwork: false, // Default to total view
        showDetailedDiskIO: false, // Default to total view
        widgetMetric1: .cpuTotal, // Default to CPU Total
        widgetMetric2: .memoryTotal, // Default to Memory Total
        pipMetric: .cpuTotal, // Default to CPU Total for PiP
        appTheme: .auto, // Default to Auto theme
        hapticsEnabled: true // Default to enabled
    )
}

@Observable
@MainActor
class SettingsManager {
    static let shared = SettingsManager()

    var settings: AppSettings {
        didSet {
            saveSettings()
            saveWidgetSettings()
        }
    }

    private let settingsKey = "app_settings"

    private init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded

            // Migration: Ensure all three network metrics are enabled
            // This handles the case where old settings only had .network
            let networkMetrics: [MetricType] = [.networkDownload, .networkUpload, .networkTotal]
            let hasAnyNetworkMetric = networkMetrics.contains { settings.enabledMetrics.contains($0) }

            // If none of the new network metrics are present, enable all of them
            if !hasAnyNetworkMetric {
                for metric in networkMetrics {
                    settings.enabledMetrics.insert(metric)
                }
                // Save the migrated settings
                saveSettings()
            }
        } else {
            self.settings = .default
        }

        // Also save widget settings to App Groups on init
        saveWidgetSettings()
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    private func saveWidgetSettings() {
        SharedDataManager.shared.saveWidgetSettings(
            metric1: settings.widgetMetric1,
            metric2: settings.widgetMetric2
        )

        // Reload all widgets to reflect the new settings
        WidgetCenter.shared.reloadAllTimelines()
    }

    func isMetricEnabled(_ type: MetricType) -> Bool {
        return settings.enabledMetrics.contains(type)
    }

    func toggleMetric(_ type: MetricType) {
        if settings.enabledMetrics.contains(type) {
            settings.enabledMetrics.remove(type)
        } else {
            settings.enabledMetrics.insert(type)
        }
    }
}
