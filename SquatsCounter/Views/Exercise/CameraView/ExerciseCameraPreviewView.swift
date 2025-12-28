//
//  CameraPreviewView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//

import UIKit
import SwiftUI
import AVFoundation

struct ExerciseCameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> InnerView {
        let view = InnerView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: InnerView, context: Context) { }
    
    final class InnerView: UIView {
        private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
        private var rotationObservation: NSKeyValueObservation?
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
        
        var session: AVCaptureSession? {
            get {
                previewLayer.session
            }
            set {
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = newValue
                coordinateRotation()
            }
        }
        
        func coordinateRotation() {
            guard let input = session?.inputs.first as? AVCaptureDeviceInput else { return }
            guard let output = session?.outputs.first as? AVCaptureVideoDataOutput else { return }
            
            rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: input.device,previewLayer: layer)
            rotationObservation = rotationCoordinator!.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.old, .new] ) { [unowned self] coordinator, change in
                guard let angle = change.newValue else { return }
                
                if let previewConnection = self.previewLayer.connection, previewConnection.isVideoRotationAngleSupported(angle) {
                    previewConnection.videoRotationAngle = angle
                }
                
                if let outputConnection = output.connection(with: .video), outputConnection.isVideoRotationAngleSupported(angle) {
                    outputConnection.videoRotationAngle = angle
                }
            }
        }
    }
}
