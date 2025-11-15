//
//  ContentView.swift
//  ActivityMonitor
//
//  Main content view with navigation (iOS 17+ design)
//

import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(SettingsManager.self) private var settingsManager
    @State private var showingSettings = false
    @State private var liveActivityActive = false
    @State private var pipManager = PictureInPictureManager.shared

    var body: some View {
        NavigationStack {
            DashboardView()
                .navigationTitle("Activity Monitor")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 8) {
                            // Live Activity Button (iOS 16.1+)
                            if #available(iOS 16.1, *) {
                                Button {
                                    toggleLiveActivity()
                                } label: {
                                    Label(
                                        liveActivityActive ? "Stop Live Activity" : "Start Live Activity",
                                        systemImage: liveActivityActive ? "livephoto.slash" : "livephoto"
                                    )
                                    .symbolRenderingMode(.multicolor)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(liveActivityActive ? .red : .purple)
                                .sensoryFeedback(.selection, trigger: liveActivityActive)
                            }

                            // Picture-in-Picture Button
                            Button {
                                togglePiP()
                            } label: {
                                Label(
                                    pipManager.isPiPActive ? "Stop PiP" : "Start PiP",
                                    systemImage: pipManager.isPiPActive ? "pip.exit" : "pip.enter"
                                )
                                .symbolRenderingMode(.monochrome)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(pipManager.isPiPActive ? .red : .cyan)
                            .disabled(!pipManager.isPiPPossible)
                            .sensoryFeedback(.selection, trigger: pipManager.isPiPActive)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.blue)
                        .sensoryFeedback(.selection, trigger: showingSettings)
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(24)
                        .presentationBackground(.ultraThinMaterial)
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
