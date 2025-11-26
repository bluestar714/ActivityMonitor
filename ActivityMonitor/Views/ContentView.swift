//
//  ContentView.swift
//  ActivityMonitor
//
//  Main content view with tab navigation (iOS 17+ design)
//

import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(SettingsManager.self) private var settingsManager
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var liveActivityActive = false
    @State private var pipManager = PictureInPictureManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationStack {
                DashboardView()
                    .navigationTitle("Dashboard")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        toolbarContent

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingSettings = true
                            } label: {
                                Label("Settings", systemImage: "gearshape.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(.blue)
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .sensoryFeedback(.selection, trigger: showingSettings) { _, _ in
                                settingsManager.settings.hapticsEnabled
                            }
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.xyaxis.line")
            }
            .tag(0)

            // Performance Tab
            NavigationStack {
                PerformanceView()
                    .navigationTitle("Performance")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Performance", systemImage: "speedometer")
            }
            .tag(1)

            // Device Info Tab
            NavigationStack {
                DeviceInfoTabView()
                    .navigationTitle("Device Info")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Device", systemImage: "cpu")
            }
            .tag(2)

            // Sensors Tab
            NavigationStack {
                SensorsView()
                    .navigationTitle("Sensors")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Sensors", systemImage: "sensor.fill")
            }
            .tag(3)
        }
        .preferredColorScheme(
            settingsManager.settings.appTheme == .auto ? nil :
            settingsManager.settings.appTheme == .dark ? .dark : .light
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 8) {
                // Live Activity Button (iOS 16.1+)
                if #available(iOS 16.1, *) {
                    Button {
                        toggleLiveActivity()
                    } label: {
                        Label(
                            liveActivityActive ? "Stop Live Activity" : "Start Live Activity",
                            systemImage: liveActivityActive ? "livephoto" : "livephoto.slash"
                        )
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 15, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(liveActivityActive ? .green : .gray)
                    .background {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: liveActivityActive ? .green.opacity(0.3) : .gray.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .sensoryFeedback(.selection, trigger: liveActivityActive) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                }

                // Picture-in-Picture Button
                Button {
                    togglePiP()
                } label: {
                    Label(
                        pipManager.isPiPActive ? "Stop PiP" : "Start PiP",
                        systemImage: pipManager.isPiPActive ? "pip.enter" : "pip.exit"
                    )
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 15, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(pipManager.isPiPActive ? .green : .gray)
                .disabled(!pipManager.isPiPPossible)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: pipManager.isPiPActive ? .green.opacity(0.3) : .gray.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .sensoryFeedback(.selection, trigger: pipManager.isPiPActive) { _, _ in
                    settingsManager.settings.hapticsEnabled
                }
            }
        }
    }

    // MARK: - Live Activity Control

    private func toggleLiveActivity() {
        if #available(iOS 16.1, *) {
            let liveActivityManager = LiveActivityManager.shared

            if liveActivityActive {
                // Stop Live Activity
                liveActivityManager.endLiveActivity()
                liveActivityActive = false
            } else {
                // Start Live Activity
                liveActivityManager.startLiveActivity(with: metricsManager.currentMetrics)
                liveActivityActive = true
            }
        }
    }

    // MARK: - Picture-in-Picture Control

    private func togglePiP() {
        if pipManager.isPiPActive {
            pipManager.stopPiP()
        } else {
            pipManager.startPiP()
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    ContentView()
        .environment(MetricsManager.shared)
        .environment(SettingsManager.shared)
}
