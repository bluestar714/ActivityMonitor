//
//  NotificationManager.swift
//  ActivityMonitor
//
//  Manages notifications for metric threshold alerts
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var notificationsEnabled = false

    // Threshold settings
    struct ThresholdSettings: Codable {
        var cpuThreshold: Double = 80.0
        var memoryThreshold: Double = 85.0
        var storageThreshold: Double = 90.0
        var notificationCooldown: TimeInterval = 300 // 5 minutes

        var cpuNotificationsEnabled = true
        var memoryNotificationsEnabled = true
        var storageNotificationsEnabled = true
    }

    @Published var thresholds = ThresholdSettings()

    private var lastNotificationTimes: [String: Date] = [:]

    private init() {
        loadThresholds()
    }

    // MARK: - Request Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            notificationsEnabled = granted

            if granted {
                print("✅ Notification permission granted")
            } else {
                print("⚠️ Notification permission denied")
            }

            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Check Metrics and Send Notifications

    func checkMetricsAndNotify(metrics: MetricsSnapshot) {
        // Check CPU
        if thresholds.cpuNotificationsEnabled && metrics.cpu.usage >= thresholds.cpuThreshold {
            sendNotification(
                identifier: "cpu_high",
                title: "High CPU Usage",
                body: String(format: "CPU usage is at %.0f%%", metrics.cpu.usage),
                category: "METRIC_ALERT"
            )
        }

        // Check Memory
        if thresholds.memoryNotificationsEnabled && metrics.memory.usagePercentage >= thresholds.memoryThreshold {
            sendNotification(
                identifier: "memory_high",
                title: "High Memory Usage",
                body: String(format: "Memory usage is at %.0f%%", metrics.memory.usagePercentage),
                category: "METRIC_ALERT"
            )
        }

        // Check Storage
        if thresholds.storageNotificationsEnabled && metrics.storage.usagePercentage >= thresholds.storageThreshold {
            sendNotification(
                identifier: "storage_high",
                title: "Low Storage Space",
                body: String(format: "Storage is %.0f%% full", metrics.storage.usagePercentage),
                category: "METRIC_ALERT"
            )
        }
    }

    // MARK: - Send Notification

    private func sendNotification(identifier: String, title: String, body: String, category: String) {
        // Check cooldown
        if let lastTime = lastNotificationTimes[identifier] {
            let timeSince = Date().timeIntervalSince(lastTime)
            if timeSince < thresholds.notificationCooldown {
                return // Still in cooldown period
            }
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category
        content.badge = 1

        // Add action buttons
        content.userInfo = ["identifier": identifier]

        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Add notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error.localizedDescription)")
            } else {
                self.lastNotificationTimes[identifier] = Date()
                print("✅ Notification sent: \(title)")
            }
        }
    }

    // MARK: - Setup Notification Categories

    func setupNotificationCategories() {
        let openAppAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open App",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )

        let metricAlertCategory = UNNotificationCategory(
            identifier: "METRIC_ALERT",
            actions: [openAppAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([metricAlertCategory])
        print("✅ Notification categories set up")
    }

    // MARK: - Clear Notifications

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ All notifications cleared")
    }

    func clearNotification(identifier: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Persistence

    private func loadThresholds() {
        if let data = UserDefaults.standard.data(forKey: "notificationThresholds"),
           let decoded = try? JSONDecoder().decode(ThresholdSettings.self, from: data) {
            thresholds = decoded
        }
    }

    func saveThresholds() {
        if let encoded = try? JSONEncoder().encode(thresholds) {
            UserDefaults.standard.set(encoded, forKey: "notificationThresholds")
        }
    }

    // MARK: - Check Permission Status

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }
}
