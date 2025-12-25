//
//  FrontContentViewModel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI
import Foundation
import AVFoundation

class FrontContentViewModel: ObservableObject {
    var captureSession: AVCaptureSession = .init()
    var captureVideoDataOutput: AVCaptureVideoDataOutput = .init()
    var frontPreviewLayer: AVCaptureVideoPreviewLayer = .init()
    
    var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    var rotationObservation: NSKeyValueObservation?
    
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private let cameraQueue = DispatchQueue(
        label: "CameraOutput",
        qos: .userInteractive
    )
    
    init(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) {
        captureSession.beginConfiguration()
        
        //Device front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(deviceInput) else {
            print(" ---> No input device.")
            return
        }
        captureSession.addInput(deviceInput)
        
        //Delegate for Vision detection
        self.delegate = delegate
        captureVideoDataOutput.setSampleBufferDelegate(self.delegate, queue: cameraQueue)
        
        //Output
        guard captureSession.canAddOutput(captureVideoDataOutput) else {
            print(" ---> No output device.")
            return
        }
        captureSession.addOutputWithNoConnections(captureVideoDataOutput)
        
        frontPreviewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: captureSession)
        frontPreviewLayer.videoGravity = .resizeAspectFill

        //Coordinator
        rotationCoordinator = .init(device: device, previewLayer: frontPreviewLayer)

        if let rotationCoordinator, let frontPort = deviceInput.ports.first(where: { $0.mediaType == .video }) {
            let frontPreviewConnection = AVCaptureConnection(inputPort: frontPort, videoPreviewLayer: frontPreviewLayer)
            if captureSession.canAddConnection(frontPreviewConnection) {
                captureSession.addConnection(frontPreviewConnection)
            }
            
            let captureVideoDataConnection = AVCaptureConnection(inputPorts: [frontPort], output: captureVideoDataOutput)
            if captureSession.canAddConnection(captureVideoDataConnection) {
                captureSession.addConnection(captureVideoDataConnection)
            }
            
            rotationObservation = rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.old, .new], changeHandler: { coordinator, change in
                
                if let connection = self.frontPreviewLayer.connection, connection.isVideoRotationAngleSupported(change.newValue!) {
                    DispatchQueue.main.async {
                        connection.videoRotationAngle = change.newValue!
                        captureVideoDataConnection.videoRotationAngle = change.newValue!
                    }
                }
            })
        }
        
        captureSession.commitConfiguration()
    }
    
    deinit {
        rotationObservation?.invalidate()
    }
}
