//
//  ActivityMonitorLiveActivity.swift
//  ActivityMonitor
//
//  Live Activities for Dynamic Island and Lock Screen
//

import ActivityKit
import SwiftUI

// MARK: - Activity Attributes

@available(iOS 16.1, *)
struct ActivityMonitorAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var cpuUsage: Double
        var memoryUsage: Double
        var networkSpeed: Double
        var timestamp: Date
    }

    var startTime: Date
}

// MARK: - Live Activity Manager

@available(iOS 16.1, *)
@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published var currentActivity: Activity<ActivityMonitorAttributes>?

    private init() {}

    // MARK: - Start Live Activity

    func startLiveActivity(with metrics: MetricsSnapshot) {
        // Check if already running
        if currentActivity != nil {
            updateLiveActivity(with: metrics)
            return
        }

        let attributes = ActivityMonitorAttributes(startTime: Date())
        let contentState = ActivityMonitorAttributes.ContentState(
            cpuUsage: metrics.cpu.usage,
            memoryUsage: metrics.memory.usagePercentage,
            networkSpeed: metrics.network.downloadSpeedMBps,
            timestamp: Date()
        )

        do {
            let activity = try Activity<ActivityMonitorAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    // MARK: - Update Live Activity

    func updateLiveActivity(with metrics: MetricsSnapshot) {
        guard let activity = currentActivity else { return }

        let contentState = ActivityMonitorAttributes.ContentState(
            cpuUsage: metrics.cpu.usage,
            memoryUsage: metrics.memory.usagePercentage,
            networkSpeed: metrics.network.downloadSpeedMBps,
            timestamp: Date()
        )

        Task {
            await activity.update(using: contentState)
        }
    }

    // MARK: - End Live Activity

    func endLiveActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ Live Activity ended")
        }
    }

    // MARK: - Check Active Activities

    func checkForActiveActivities() {
        Task {
            for activity in Activity<ActivityMonitorAttributes>.activities {
                currentActivity = activity
                print("✅ Found existing Live Activity: \(activity.id)")
                break
            }
        }
    }
}
