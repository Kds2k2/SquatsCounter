//
//  ExerciseCameraViewModel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI
import Foundation
import AVFoundation

class ExerciseCameraViewModel {
    var captureSession: AVCaptureSession = .init()
    var captureVideoDataOutput: AVCaptureVideoDataOutput = .init()
    var captureDevice: AVCaptureDevice?
    
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private let cameraQueue = DispatchQueue(
        label: "ExerciseCameraViewModel",
        qos: .userInteractive
    )
    
    init(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // INPUT
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(deviceInput) else {
            LogManager.shared.error("No Input.")
            return
        }
        captureSession.addInput(deviceInput)
        self.captureDevice = device
        
        // OUTPUT
        guard captureSession.canAddOutput(captureVideoDataOutput) else {
            LogManager.shared.error("No Output.")
            return
        }
        captureSession.addOutput(captureVideoDataOutput)
        
        // DELEGATE
        self.delegate = delegate
        captureVideoDataOutput.setSampleBufferDelegate(self.delegate, queue: cameraQueue)
    }
}
