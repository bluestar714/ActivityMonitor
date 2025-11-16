//
//  GraphRenderer.swift
//  ActivityMonitor
//
//  Service to render SwiftUI views as video frames for Picture-in-Picture
//

import SwiftUI
import UIKit
import AVFoundation
import CoreVideo

@available(iOS 17.0, *)
class GraphRenderer {
    static let shared = GraphRenderer()

    // Rendering settings
    private let renderSize = CGSize(width: 640, height: 360) // 16:9 aspect ratio
    private let frameRate: Int32 = 30

    private init() {}

    // MARK: - SwiftUI to UIImage

    /// Renders a SwiftUI view to a UIImage using ImageRenderer (iOS 16+)
    @MainActor
    func renderView<Content: View>(@ViewBuilder content: () -> Content, colorScheme: ColorScheme) -> UIImage? {
        // Use ImageRenderer for completely off-screen rendering
        let renderer = ImageRenderer(content: content().environment(\.colorScheme, colorScheme))

        // Set the rendering size
        renderer.proposedSize = ProposedViewSize(width: renderSize.width, height: renderSize.height)

        // Set scale for crisp rendering
        renderer.scale = UIScreen.main.scale

        // Render to UIImage
        guard let image = renderer.uiImage else {
            print("❌ Failed to render view to image")
            return nil
        }

        print("✅ Rendered view to image: \(image.size)")
        return image
    }

    // MARK: - UIImage to CVPixelBuffer

    /// Converts a UIImage to a CVPixelBuffer
    func imageToPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(renderSize.width),
            Int(renderSize.height),
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("❌ Failed to create pixel buffer")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(renderSize.width),
            height: Int(renderSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            print("❌ Failed to create CGContext")
            return nil
        }

        // Draw image (background is already included in the rendered image)
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: renderSize))
        }

        return buffer
    }

    // MARK: - Complete Pipeline

    /// Renders a SwiftUI view directly to a CVPixelBuffer
    @MainActor
    func renderToPixelBuffer<Content: View>(@ViewBuilder content: () -> Content, colorScheme: ColorScheme) -> CVPixelBuffer? {
        guard let image = renderView(content: content, colorScheme: colorScheme) else {
            print("❌ Failed to render view to image")
            return nil
        }

        return imageToPixelBuffer(image: image)
    }

    // MARK: - Metrics Rendering for PiP

    /// Renders the metrics view optimized for Picture-in-Picture
    @MainActor
    func renderMetrics(
        metricsManager: MetricsManager,
        settingsManager: SettingsManager
    ) -> CVPixelBuffer? {
        print("🎨 Rendering metrics for PiP...")

        // Determine color scheme from app theme
        let colorScheme: ColorScheme = settingsManager.settings.appTheme == .dark ? .dark : .light

        return renderToPixelBuffer(content: {
            PiPMetricsView(
                metricsManager: metricsManager,
                settingsManager: settingsManager
            )
            .frame(width: renderSize.width, height: renderSize.height, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 0))
        }, colorScheme: colorScheme)
    }
}
