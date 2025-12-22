//
//  CreateCustomExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import SwiftUI
import AVFoundation
import Vision

enum CreationState {
    case recording
    case reviewing
}

struct CreateCustomExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var recorderViewModel = VideoRecorderViewModel()
    
    @State private var state: CreationState = .recording
    @State private var name = ""
    @State private var repeatCount = 10
    @State private var startTime: Double?
    @State private var endTime: Double?
    @State private var currentTime: Double = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var player: AVPlayer?
    @State private var videoDuration: Double = 0
    @State private var timeObserver: Any?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if state == .recording {
                    recordingView
                } else {
                    reviewingView
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Create Custom Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        cleanup()
                        dismiss()
                    }
                }
                if state == .reviewing {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveExercise()
                        }
                        .disabled(!canSave)
                    }
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onDisappear {
                cleanup()
            }
        }
    }
    
    private var recordingView: some View {
        ZStack {
            FrontCameraPreviewView(previewLayer: recorderViewModel.frontPreviewLayer)
                .onAppear {
                    recorderViewModel.startSession()
                }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(recorderViewModel.isRecording ? Color.red : Color.white)
                                .frame(width: 70, height: 70)
                            
                            if recorderViewModel.isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                            } else {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            
            if recorderViewModel.isRecording {
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                        Text("Recording")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
            }
        }
        .onChange(of: recorderViewModel.recordedVideoURL) { _, newURL in
            if let url = newURL {
                setupVideoPlayer(url: url)
                state = .reviewing
            }
        }
    }
    
    private var reviewingView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if let player = player {
                    VideoPlayerView(player: player)
                        .frame(height: geometry.size.height * 0.5)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: geometry.size.height * 0.5)
                }
                
                VStack(spacing: 16) {
                    if let videoURL = recorderViewModel.recordedVideoURL {
                        VideoTimelineView(
                            videoURL: videoURL,
                            videoDuration: videoDuration,
                            startTime: $startTime,
                            endTime: $endTime,
                            currentTime: $currentTime,
                            onSeek: seekTo
                        )
                    }
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        TextField("Exercise name", text: $name)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Text("Repeat count:")
                            Spacer()
                            Picker("Repeat count", selection: $repeatCount) {
                                ForEach(1...100, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    private var canSave: Bool {
        !name.isEmpty && startTime != nil && endTime != nil
    }
    
    private func toggleRecording() {
        if recorderViewModel.isRecording {
            recorderViewModel.stopRecording()
        } else {
            recorderViewModel.startRecording()
        }
    }
    
    private func setupVideoPlayer(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                await MainActor.run {
                    videoDuration = CMTimeGetSeconds(duration)
                }
            } catch {
                print("Failed to load video duration: \(error)")
            }
        }
        
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
        }
    }
    
    private func seekTo(_ time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        player?.pause()
    }
    
    private func saveExercise() {
        guard let start = startTime, let end = endTime else {
            alertMessage = "Please set both start and end times"
            showAlert = true
            return
        }
        
        guard !name.isEmpty else {
            alertMessage = "Please enter an exercise name"
            showAlert = true
            return
        }
        
        guard let videoURL = recorderViewModel.recordedVideoURL else {
            alertMessage = "Video not available"
            showAlert = true
            return
        }
        
        if abs(start - end) < 0.5 {
            alertMessage = "Start and end times are too close. Please choose more distinct times."
            showAlert = true
            return
        }
        
        Task {
            do {
                let startAngles = try await extractAngles(from: videoURL, at: start)
                let endAngles = try await extractAngles(from: videoURL, at: end)
                
                await MainActor.run {
                    let customExercise = CustomExercise(
                        name: name,
                        startState: startAngles,
                        endState: endAngles
                    )
                    
                    let exercise = Exercise(
                        name: name,
                        type: .custom,
                        requiredCount: repeatCount,
                        customExercise: customExercise
                    )
                    
                    modelContext.insert(exercise)
                    try? modelContext.save()
                    
                    cleanup()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to extract poses from video: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func extractAngles(from videoURL: URL, at time: Double) async throws -> Angles {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let cgImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
        
        let bodyParts = try await detectPose(in: cgImage)
        
        guard let leftShoulder = bodyParts[.leftShoulder],
              let rightShoulder = bodyParts[.rightShoulder],
              let leftElbow = bodyParts[.leftElbow],
              let rightElbow = bodyParts[.rightElbow],
              let leftWrist = bodyParts[.leftWrist],
              let rightWrist = bodyParts[.rightWrist],
              let leftHip = bodyParts[.leftHip],
              let rightHip = bodyParts[.rightHip],
              let leftKnee = bodyParts[.leftKnee],
              let rightKnee = bodyParts[.rightKnee],
              let leftAnkle = bodyParts[.leftAnkle],
              let rightAnkle = bodyParts[.rightAnkle] else {
            throw NSError(domain: "CreateCustomExerciseView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not detect all required body parts"])
        }
        
        let leftHandAngle = calculateAngle(p1: leftElbow, p2: leftShoulder, p3: leftWrist)
        let rightHandAngle = calculateAngle(p1: rightElbow, p2: rightShoulder, p3: rightWrist)
        let leftLegAngle = calculateAngle(p1: leftKnee, p2: leftHip, p3: leftAnkle)
        let rightLegAngle = calculateAngle(p1: rightKnee, p2: rightHip, p3: rightAnkle)
        
        return Angles(
            leftHand: leftHandAngle,
            rightHand: rightHandAngle,
            leftLeg: leftLegAngle,
            rightLeg: rightLegAngle
        )
    }
    
    private func detectPose(in image: CGImage) async throws -> [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] {
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        try handler.perform([request])
        
        guard let observation = request.results?.first else {
            throw NSError(domain: "CreateCustomExerciseView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No pose detected"])
        }
        
        var bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
        
        let joints: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]
        
        for joint in joints {
            if let point = try? observation.recognizedPoint(joint), point.confidence > 0.5 {
                bodyParts[joint] = point
            }
        }
        
        return bodyParts
    }
    
    private func calculateAngle(p1: VNRecognizedPoint, p2: VNRecognizedPoint, p3: VNRecognizedPoint) -> CGFloat {
        let point1 = CGPoint(x: p1.location.x, y: 1 - p1.location.y)
        let point2 = CGPoint(x: p2.location.x, y: 1 - p2.location.y)
        let point3 = CGPoint(x: p3.location.x, y: 1 - p3.location.y)
        
        let v1 = CGPoint(x: point2.x - point1.x, y: point2.y - point1.y)
        let v2 = CGPoint(x: point3.x - point1.x, y: point3.y - point1.y)
        
        let dot = v1.x * v2.x + v1.y * v2.y
        let mag1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let mag2 = sqrt(v2.x * v2.x + v2.y * v2.y)
        
        guard mag1 > 0, mag2 > 0 else { return 0 }
        var angle = acos(dot / (mag1 * mag2)) * 180 / .pi
        
        if angle > 180 {
            angle = 360 - angle
        }
        return angle
    }
    
    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        recorderViewModel.stopSession()
    }
}
