//
//  BackgroundTaskManager.swift
//  ActivityMonitor
//
//  Manages background tasks for metrics collection and widget updates
//

import Foundation
import BackgroundTasks
import WidgetKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    // Background task identifiers
    private let refreshTaskIdentifier = "com.activitymonitor.app.refresh"
    private let cleanupTaskIdentifier = "com.activitymonitor.app.cleanup"

    private init() {}

    // MARK: - Register Background Tasks

    func registerBackgroundTasks() {
        // Register background refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        // Register background cleanup task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: cleanupTaskIdentifier,
            using: nil
        ) { task in
            self.handleCleanup(task: task as! BGProcessingTask)
        }

        print("✅ Background tasks registered")
    }

    // MARK: - Schedule Background Tasks

    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)

        // Schedule to run in 15 minutes
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background refresh scheduled")
        } catch {
            print("❌ Could not schedule background refresh: \(error.localizedDescription)")
        }
    }

    func scheduleBackgroundCleanup() {
        let request = BGProcessingTaskRequest(identifier: cleanupTaskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        // Schedule to run daily
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background cleanup scheduled")
        } catch {
            print("❌ Could not schedule background cleanup: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Background Refresh

    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("📱 Background refresh started")

        // Schedule next refresh
        scheduleBackgroundRefresh()

        // Create expiration handler
        task.expirationHandler = {
            print("⚠️ Background refresh expired")
            task.setTaskCompleted(success: false)
        }

        // Perform background work
        Task {
            do {
                // Collect fresh metrics
                let collector = SystemMetricsCollector()
                let metrics = collector.collectAllMetrics()

                // Save to shared storage
                let sharedDataManager = SharedDataManager.shared
                sharedDataManager.saveCurrentMetrics(metrics)

                // Update widgets
                WidgetCenter.shared.reloadAllTimelines()

                // Update Live Activities if iOS 16.1+
                if #available(iOS 16.1, *) {
                    let liveActivityManager = await LiveActivityManager.shared
                    await liveActivityManager.updateLiveActivity(with: metrics)
                }

                print("✅ Background refresh completed")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Background refresh failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    // MARK: - Handle Background Cleanup

    private func handleCleanup(task: BGProcessingTask) {
        print("🧹 Background cleanup started")

        // Schedule next cleanup
        scheduleBackgroundCleanup()

        // Create expiration handler
        task.expirationHandler = {
            print("⚠️ Background cleanup expired")
            task.setTaskCompleted(success: false)
        }

        // Perform cleanup work
        Task {
            do {
                // Clean old data from shared storage
                // This is a placeholder - implement actual cleanup logic as needed

                print("✅ Background cleanup completed")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Background cleanup failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    // MARK: - Cancel All Tasks

    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        print("✅ All background tasks cancelled")
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension BackgroundTaskManager {
    func simulateBackgroundRefresh() {
        print("🔧 Simulating background refresh...")

        // Create a simulated task
        let collector = SystemMetricsCollector()
        let metrics = collector.collectAllMetrics()

        let sharedDataManager = SharedDataManager.shared
        sharedDataManager.saveCurrentMetrics(metrics)

        WidgetCenter.shared.reloadAllTimelines()

        print("✅ Simulated background refresh completed")
    }
}
#endif
