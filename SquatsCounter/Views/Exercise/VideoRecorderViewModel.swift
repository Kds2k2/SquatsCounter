//
//  VideoRecorderViewModel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import SwiftUI
import Foundation
import AVFoundation

class VideoRecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var recordedVideoURL: URL?
    
    private var captureSession: AVCaptureSession
    private var movieFileOutput: AVCaptureMovieFileOutput?
    var frontPreviewLayer: AVCaptureVideoPreviewLayer
    
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    
    init() {
        captureSession = AVCaptureSession()
        frontPreviewLayer = AVCaptureVideoPreviewLayer()
        
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(deviceInput) else {
            print("Failed to setup camera input")
            return
        }
        captureSession.addInput(deviceInput)
        
        movieFileOutput = AVCaptureMovieFileOutput()
        guard let movieFileOutput = movieFileOutput,
              captureSession.canAddOutput(movieFileOutput) else {
            print("Failed to setup movie file output")
            return
        }
        captureSession.addOutput(movieFileOutput)
        
        frontPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        frontPreviewLayer.videoGravity = .resizeAspectFill
        
        rotationCoordinator = .init(device: device, previewLayer: frontPreviewLayer)
        
        if let rotationCoordinator {
            rotationObservation = rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.old, .new], changeHandler: { [weak self] coordinator, change in
                guard let self = self,
                      let connection = self.frontPreviewLayer.connection,
                      let newAngle = change.newValue,
                      connection.isVideoRotationAngleSupported(newAngle) else { return }
                
                DispatchQueue.main.async {
                    connection.videoRotationAngle = newAngle
                }
            })
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        Task.detached { [weak self] in
            await self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        Task.detached { [weak self] in
            await self?.captureSession.stopRunning()
        }
    }
    
    func startRecording() {
        guard let movieFileOutput = movieFileOutput, !isRecording else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mov"
        let outputURL = tempDir.appendingPathComponent(fileName)
        
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: MovieFileOutputDelegate { [weak self] url in
            DispatchQueue.main.async {
                self?.recordedVideoURL = url
                self?.isRecording = false
            }
        })
        
        isRecording = true
    }
    
    func stopRecording() {
        movieFileOutput?.stopRecording()
    }
    
    deinit {
        rotationObservation?.invalidate()
    }
}

private class MovieFileOutputDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    private let completion: (URL) -> Void
    
    init(completion: @escaping (URL) -> Void) {
        self.completion = completion
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
            return
        }
        completion(outputFileURL)
    }
}
