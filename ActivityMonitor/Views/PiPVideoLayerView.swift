//
//  PiPVideoLayerView.swift
//  ActivityMonitor
//
//  SwiftUI wrapper for AVSampleBufferDisplayLayer used in Picture-in-Picture
//

import SwiftUI
import AVFoundation

@available(iOS 17.0, *)
struct PiPVideoLayerView: UIViewRepresentable {
    let onLayerReady: (AVSampleBufferDisplayLayer) -> Void

    func makeUIView(context: Context) -> PiPContainerView {
        let view = PiPContainerView()
        onLayerReady(view.displayLayer)
        return view
    }

    func updateUIView(_ uiView: PiPContainerView, context: Context) {
        // No updates needed
    }
}

@available(iOS 17.0, *)
class PiPContainerView: UIView {
    let displayLayer: AVSampleBufferDisplayLayer

    override init(frame: CGRect) {
        displayLayer = AVSampleBufferDisplayLayer()
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        displayLayer = AVSampleBufferDisplayLayer()
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        displayLayer.videoGravity = .resizeAspect
        displayLayer.frame = bounds
        layer.addSublayer(displayLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        displayLayer.frame = bounds
    }
}
