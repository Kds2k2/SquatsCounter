//
//  VideoRecorderViewModel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import Photos
import SwiftUI
import Foundation
import AVFoundation

class VideoRecorderViewModel: ObservableObject {
    var captureSession: AVCaptureSession = .init()
    var captureMovieFileOutput: AVCaptureMovieFileOutput = .init()
    var frontPreviewLayer: AVCaptureVideoPreviewLayer = .init()
    
    var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    var rotationObservation: NSKeyValueObservation?
    
    weak var delegate: AVCaptureFileOutputRecordingDelegate?
    private let videoQueue = DispatchQueue(
        label: "PatternQueue",
        qos: .userInteractive
    )
    
    @Published var isRecording: Bool = false
    
    init(_ delegate: AVCaptureFileOutputRecordingDelegate?) {
        captureSession.beginConfiguration()
        
        //Device front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let deviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(deviceInput) else {
            print("--> No input device.")
            return
        }
        captureSession.addInput(deviceInput)
        
        //Delegate
        self.delegate = delegate
        
        //Output
        guard captureSession.canAddOutput(captureMovieFileOutput) else {
            print("--> No output device.")
            return
        }
        captureSession.addOutputWithNoConnections(captureMovieFileOutput)
        
        frontPreviewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: captureSession)
        frontPreviewLayer.videoGravity = .resizeAspectFill
        
        //Coordinator
        rotationCoordinator = .init(device: device, previewLayer: frontPreviewLayer)

        if let rotationCoordinator, let frontPort = deviceInput.ports.first(where: { $0.mediaType == .video }) {
            let frontPreviewConnection = AVCaptureConnection(inputPort: frontPort, videoPreviewLayer: frontPreviewLayer)
            if captureSession.canAddConnection(frontPreviewConnection) {
                captureSession.addConnection(frontPreviewConnection)
            }
            
            let captureMovieFileConnection = AVCaptureConnection(inputPorts: [frontPort], output: captureMovieFileOutput)
            if captureSession.canAddConnection(captureMovieFileConnection) {
                captureSession.addConnection(captureMovieFileConnection)
            }
            
            rotationObservation = rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.old, .new], changeHandler: { coordinator, change in
                
                if let connection = self.frontPreviewLayer.connection, connection.isVideoRotationAngleSupported(change.newValue!) {
                    DispatchQueue.main.async {
                        connection.videoRotationAngle = change.newValue!
                        captureMovieFileConnection.videoRotationAngle = change.newValue!
                    }
                }
            })
        }
        
        captureSession.commitConfiguration()
    }
    
    //MARK: - Recording
    func startRecording() {
        LogManager.shared.debug("Start recording.")
        guard let delegate = self.delegate else { return }
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("video1.mp4") else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        
        videoQueue.async {
            self.captureMovieFileOutput.startRecording(to: url, recordingDelegate: delegate)
        }
        isRecording = true
    }

    func stopRecording() {
        videoQueue.async {
            LogManager.shared.debug("Stop recording.")
            self.captureMovieFileOutput.stopRecording()
        }
        isRecording = false
    }
}
