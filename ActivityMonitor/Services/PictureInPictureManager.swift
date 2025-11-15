//
//  PictureInPictureManager.swift
//  ActivityMonitor
//
//  Service to manage Picture-in-Picture video playback of metrics graphs
//

import SwiftUI
import AVFoundation
import AVKit
import Combine

@available(iOS 17.0, *)
@Observable
class PictureInPictureManager: NSObject {
    static let shared = PictureInPictureManager()

    // PiP State
    private(set) var isPiPActive = false
    private(set) var isPiPPossible = false

    // AVFoundation components
    private var displayLayer: AVSampleBufferDisplayLayer?
    private var pipController: AVPictureInPictureController?

    // Frame generation
    private var renderTimer: Timer?
    private let frameRate: Double = 1.0 // Update every 1 second (1fps)

    // Metrics references
    private weak var metricsManager: MetricsManager?
    private weak var settingsManager: SettingsManager?

    // Sample buffer management
    private var sampleBufferQueue: DispatchQueue
    private var formatDescription: CMFormatDescription?
    private var presentationTime: CMTime = .zero
    private var timebase: CMTimebase?

    private override init() {
        self.sampleBufferQueue = DispatchQueue(label: "com.activitymonitor.samplebuffer")
        super.init()
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Set category to playback to support background PiP
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("✅ Audio session configured for PiP")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }

    // MARK: - PiP Setup

    func setup(with layer: AVSampleBufferDisplayLayer, metricsManager: MetricsManager, settingsManager: SettingsManager) {
        self.displayLayer = layer
        self.metricsManager = metricsManager
        self.settingsManager = settingsManager

        // Configure display layer
        layer.videoGravity = .resizeAspect

        // Prevent flickering by not removing old frames immediately
        if #available(iOS 14.0, *) {
            layer.preventsDisplaySleepDuringVideoPlayback = false
        }

        // Create and configure timebase for smoother playback
        var timebase: CMTimebase?
        CMTimebaseCreateWithSourceClock(
            allocator: kCFAllocatorDefault,
            sourceClock: CMClockGetHostTimeClock(),
            timebaseOut: &timebase
        )

        if let timebase = timebase {
            self.timebase = timebase
            layer.controlTimebase = timebase
            CMTimebaseSetRate(timebase, rate: 1.0)
            CMTimebaseSetTime(timebase, time: .zero)
        }

        // Create PiP controller
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("❌ PiP not supported on this device")
            return
        }

        do {
            let pipController = try AVPictureInPictureController(
                contentSource: .init(
                    sampleBufferDisplayLayer: layer,
                    playbackDelegate: self
                )
            )
            self.pipController = pipController
            pipController.delegate = self
            pipController.canStartPictureInPictureAutomaticallyFromInline = false

            isPiPPossible = true
            print("✅ PiP controller initialized")

            // Generate initial frame to prepare the layer
            Task { @MainActor in
                generateFrame()
            }
        } catch {
            print("❌ Failed to create PiP controller: \(error)")
        }
    }

    // MARK: - PiP Control

    func startPiP() {
        guard let pipController = pipController,
              isPiPPossible,
              !isPiPActive else {
            print("⚠️ Cannot start PiP: not ready")
            return
        }

        print("▶️ Starting PiP...")

        // Start rendering frames
        startFrameGeneration()

        // Wait a bit for frames to be generated, then start PiP
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                pipController.startPictureInPicture()
                print("✅ PiP start requested")
            }
        }
    }

    func stopPiP() {
        guard let pipController = pipController else { return }

        // Stop PiP
        pipController.stopPictureInPicture()

        // Stop rendering frames
        stopFrameGeneration()

        print("⏸️ Stopping PiP...")
    }

    // MARK: - Frame Generation

    private func startFrameGeneration() {
        // Ensure we're on the main thread
        Task { @MainActor in
            // Generate initial frame immediately
            generateFrame()

            // Schedule timer for periodic updates
            renderTimer = Timer.scheduledTimer(
                withTimeInterval: 1.0 / frameRate,
                repeats: true
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.generateFrame()
                }
            }

            print("✅ Frame generation started at \(frameRate) fps")
        }
    }

    private func stopFrameGeneration() {
        renderTimer?.invalidate()
        renderTimer = nil
        print("⏹️ Frame generation stopped")
    }

    @MainActor
    private func generateFrame() {
        guard let metricsManager = metricsManager,
              let settingsManager = settingsManager,
              let displayLayer = displayLayer else {
            print("⚠️ Cannot generate frame: missing dependencies")
            return
        }

        // Render the metrics view to a pixel buffer (on main thread)
        guard let pixelBuffer = GraphRenderer.shared.renderMetrics(
            metricsManager: metricsManager,
            settingsManager: settingsManager
        ) else {
            print("❌ Failed to generate frame")
            return
        }

        // Create and enqueue sample buffer (can be done on background thread)
        sampleBufferQueue.async { [weak self] in
            guard let self = self else { return }

            // Create sample buffer
            guard let sampleBuffer = self.createSampleBuffer(from: pixelBuffer) else {
                print("❌ Failed to create sample buffer")
                return
            }

            // Enqueue sample buffer without flushing (prevents flickering)
            displayLayer.enqueue(sampleBuffer)

            print("✅ Frame enqueued at time: \(self.presentationTime.seconds)")

            // Increment presentation time for smooth transitions
            self.presentationTime = CMTimeAdd(
                self.presentationTime,
                CMTime(value: 1, timescale: 1) // 1 second intervals
            )
        }
    }

    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        // Create format description if needed
        if formatDescription == nil {
            var formatDesc: CMFormatDescription?
            let status = CMVideoFormatDescriptionCreateForImageBuffer(
                allocator: kCFAllocatorDefault,
                imageBuffer: pixelBuffer,
                formatDescriptionOut: &formatDesc
            )

            guard status == noErr, let formatDesc = formatDesc else {
                print("❌ Failed to create format description")
                return nil
            }

            formatDescription = formatDesc
        }

        guard let formatDescription = formatDescription else {
            return nil
        }

        // Create timing info with 1 second duration for smooth playback
        var timingInfo = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: 1),
            presentationTimeStamp: presentationTime,
            decodeTimeStamp: .invalid
        )

        // Create sample buffer
        var sampleBuffer: CMSampleBuffer?
        let status = CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        guard status == noErr else {
            print("❌ Failed to create sample buffer: \(status)")
            return nil
        }

        return sampleBuffer
    }

    // MARK: - Cleanup

    func cleanup() {
        stopPiP()
        displayLayer = nil
        pipController = nil
        metricsManager = nil
        settingsManager = nil
        formatDescription = nil
        presentationTime = .zero
    }
}

// MARK: - AVPictureInPictureControllerDelegate

@available(iOS 17.0, *)
extension PictureInPictureManager: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📺 PiP will start")
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = true
        print("✅ PiP started")
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📺 PiP will stop")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPiPActive = false
        stopFrameGeneration()
        print("⏹️ PiP stopped")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("❌ PiP failed to start: \(error.localizedDescription)")
        stopFrameGeneration()
    }
}

// MARK: - AVPictureInPictureSampleBufferPlaybackDelegate

@available(iOS 17.0, *)
extension PictureInPictureManager: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        setPlaying playing: Bool
    ) {
        // Handle play/pause from PiP controls
        if playing {
            startFrameGeneration()
        } else {
            stopFrameGeneration()
        }
        print("📺 PiP playback: \(playing ? "playing" : "paused")")
    }

    func pictureInPictureControllerTimeRangeForPlayback(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> CMTimeRange {
        // Return an indefinite time range for continuous playback
        return CMTimeRange(start: .zero, duration: .positiveInfinity)
    }

    func pictureInPictureControllerIsPlaybackPaused(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> Bool {
        // We're always "playing" when PiP is active
        return renderTimer == nil
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        didTransitionToRenderSize newRenderSize: CMVideoDimensions
    ) {
        print("📺 PiP render size changed: \(newRenderSize.width)x\(newRenderSize.height)")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime
    ) async {
        // Skip is not applicable for live metrics
        print("📺 Skip requested (ignored for live metrics)")
    }
}
