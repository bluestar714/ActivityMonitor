//
//  Settings.swift
//  ActivityMonitor
//
//  User settings and preferences (iOS 17+)
//

import Foundation
import Observation
import WidgetKit

struct AppSettings: Codable {
    var enabledMetrics: Set<MetricType>
    var refreshInterval: TimeInterval // In seconds
    var historyDuration: TimeInterval // How long to keep data
    var maxDataPoints: Int
    var showDetailedCPU: Bool // Show User/System breakdown instead of total
    var widgetMetric1: MetricType // First metric to show in widget
    var widgetMetric2: MetricType // Second metric to show in widget
    var pipMetric: MetricType // Metric to show in Picture-in-Picture

    static let `default` = AppSettings(
        enabledMetrics: Set(MetricType.allCases),
        refreshInterval: 1.0,
        historyDuration: 300.0, // 5 minutes
        maxDataPoints: 300,
        showDetailedCPU: false, // Default to total view
        widgetMetric1: .cpu, // Default to CPU
        widgetMetric2: .memory, // Default to Memory
        pipMetric: .cpu // Default to CPU for PiP
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
