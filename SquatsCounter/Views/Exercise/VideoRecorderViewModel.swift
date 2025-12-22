//
//  VideoRecorderViewModel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import SwiftUI
import Foundation
import AVFoundation

class VideoRecorderViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var recordedVideoURL: URL?
    
    private var captureSession: AVCaptureSession
    private var movieFileOutput: AVCaptureMovieFileOutput?
    var frontPreviewLayer: AVCaptureVideoPreviewLayer
    
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?

    private var recordingCompletion: ((Result<URL, Error>) -> Void)?

    private func setIsRecording(_ value: Bool) {
        if Thread.isMainThread {
            isRecording = value
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isRecording = value
            }
        }
    }
    
    override init() {
        captureSession = AVCaptureSession()
        frontPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        super.init()
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func startRecording() {
        guard let movieFileOutput = movieFileOutput, !isRecording else { 
            print("⚠️ Already recording or no movie file output available")
            return 
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mov"
        let outputURL = tempDir.appendingPathComponent(fileName)
        
        recordedVideoURL = nil
        
        print("🎥 Starting recording to: \(outputURL)")

        recordingCompletion = { [weak self] result in
            print("🎬 Recording completion called with result")
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    print("✅ Recording completed successfully at: \(url)")
                    self?.recordedVideoURL = url
                case .failure(let error):
                    print("❌ Recording error: \(error.localizedDescription)")
                    self?.recordedVideoURL = nil
                }
                print("🔄 Setting isRecording to false")
                self?.isRecording = false
                self?.recordingCompletion = nil
            }
        }
        
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)

        print("🔴 Setting isRecording to true")
        setIsRecording(true)
    }
    
    func stopRecording() {
        guard isRecording else { 
            print("⚠️ Not currently recording, ignoring stop request")
            return 
        }
        print("⏹️ Stopping recording...")
        setIsRecording(false)
        movieFileOutput?.stopRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.recordedVideoURL == nil, self?.recordingCompletion != nil {
                print("⚠️ Recording stop delegate not called, forcing state update")
                self?.recordingCompletion?(.failure(NSError(domain: "VideoRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording failed to complete"])))
            }
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("⏺️ Started recording to \(fileURL)")
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("⏹️ Finished recording to \(outputFileURL)")
        if let error = error {
            print("❌ Recording error: \(error.localizedDescription)")
            recordingCompletion?(.failure(error))
            return
        }
        print("✅ Recording completed successfully")
        recordingCompletion?(.success(outputFileURL))
    }
    
    deinit {
        rotationObservation?.invalidate()
        recordingCompletion = nil
    }
}
