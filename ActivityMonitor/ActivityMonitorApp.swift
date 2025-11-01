//
//  ActivityMonitorApp.swift
//  ActivityMonitor
//
//  Main entry point for the Activity Monitor iOS app (iOS 17+)
//

import SwiftUI

@available(iOS 17.0, *)
@main
struct ActivityMonitorApp: App {
    @State private var metricsManager = MetricsManager.shared
    @State private var settingsManager = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(metricsManager)
                .environment(settingsManager)
                .onAppear {
                    metricsManager.startMonitoring()
                }
                .onDisappear {
                    metricsManager.stopMonitoring()
                }
        }
    }
}
