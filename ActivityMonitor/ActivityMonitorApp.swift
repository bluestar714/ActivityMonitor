//
//  ActivityMonitorApp.swift
//  ActivityMonitor
//
//  Main entry point for the Activity Monitor iOS app (iOS 17+)
//

import SwiftUI
import UserNotifications

@available(iOS 17.0, *)
@main
struct ActivityMonitorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var metricsManager = MetricsManager.shared
    @State private var settingsManager = SettingsManager.shared
    @State private var notificationManager = NotificationManager.shared

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(metricsManager)
                .environment(settingsManager)
                .environment(notificationManager)
                .onAppear {
                    setupApp()
                    metricsManager.startMonitoring()
                }
                .onDisappear {
                    // Don't stop monitoring - continue in background
                    handleBackground()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }

    // MARK: - Setup

    private func setupApp() {
        // Setup notifications
        Task {
            await notificationManager.requestAuthorization()
            await notificationManager.checkAuthorizationStatus()
        }
        notificationManager.setupNotificationCategories()

        // Check for existing Live Activities
        if #available(iOS 16.1, *) {
            Task {
                await LiveActivityManager.shared.checkForActiveActivities()
            }
        }

        print("✅ App setup completed")
    }

    // MARK: - Background Handling

    private func handleBackground() {
        // Save data to shared storage for widgets
        metricsManager.saveToSharedStorage()

        // Schedule background tasks
        BackgroundTaskManager.shared.scheduleBackgroundRefresh()

        print("📱 App entering background - data saved")
    }

    // MARK: - Scene Phase Changes

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            print("📱 App became active")
            metricsManager.startMonitoring()

        case .inactive:
            print("📱 App became inactive")

        case .background:
            print("📱 App entered background")
            handleBackground()

        @unknown default:
            break
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Register background tasks
        BackgroundTaskManager.shared.registerBackgroundTasks()

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        print("✅ App delegate initialized")
        return true
    }

    // MARK: - Notification Delegate Methods

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier

        switch identifier {
        case "OPEN_APP":
            print("📱 User tapped 'Open App' on notification")
            // App is already opening

        case "DISMISS":
            print("📱 User dismissed notification")

        default:
            print("📱 User tapped notification")
        }

        completionHandler()
    }
}

// MARK: - Background Task Handler

extension AppDelegate {
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        print("📱 Background URL session event: \(identifier)")
        completionHandler()
    }
}
