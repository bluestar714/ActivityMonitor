//
//  Settings.swift
//  ActivityMonitor
//
//  User settings and preferences (iOS 17+)
//

import Foundation
import Observation

struct AppSettings: Codable {
    var enabledMetrics: Set<MetricType>
    var refreshInterval: TimeInterval // In seconds
    var historyDuration: TimeInterval // How long to keep data
    var maxDataPoints: Int

    static let `default` = AppSettings(
        enabledMetrics: Set(MetricType.allCases),
        refreshInterval: 1.0,
        historyDuration: 300.0, // 5 minutes
        maxDataPoints: 300
    )
}

@Observable
@MainActor
class SettingsManager {
    static let shared = SettingsManager()

    var settings: AppSettings {
        didSet {
            saveSettings()
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
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
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
