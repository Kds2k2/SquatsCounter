//
//  CreateCustomExerciseView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import SwiftUI
import Vision

struct CreateCustomExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var poseEstimator: PoseEstimator
    @StateObject private var viewModel: FrontContentViewModel
    
    @State private var name = ""
    @State private var repeatCount = 10
    @State private var startAngles: Angles?
    @State private var endAngles: Angles?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init() {
        let estimator = PoseEstimator()
        _poseEstimator = StateObject(wrappedValue: estimator)
        _viewModel = StateObject(wrappedValue: FrontContentViewModel(estimator))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    FrontCameraPreviewView(previewLayer: viewModel.frontPreviewLayer)
                        .onAppear {
                            Task.detached {
                                await viewModel.captureSession.startRunning()
                            }
                        }
                        .onDisappear {
                            Task.detached {
                                await viewModel.captureSession.stopRunning()
                            }
                        }
                    
                    StickFigureView(
                        postEstimator: poseEstimator,
                        size: geometry.size,
                        exercise: .custom
                    )
                    
                    VStack {
                        Spacer()
                        
                        controlsPanel
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .padding()
                    }
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Create Custom Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var controlsPanel: some View {
        VStack(spacing: 16) {
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
            
            Divider()
            
            VStack(spacing: 12) {
                Button(action: captureStartPosition) {
                    HStack {
                        Image(systemName: startAngles == nil ? "1.circle" : "checkmark.circle.fill")
                        Text("Capture Start Position")
                        Spacer()
                    }
                    .foregroundColor(startAngles == nil ? .primary : .green)
                }
                .buttonStyle(.bordered)
                .disabled(!hasValidPose)
                
                if let angles = startAngles {
                    anglesDisplay(angles, title: "Start")
                        .font(.caption)
                }
                
                Button(action: captureEndPosition) {
                    HStack {
                        Image(systemName: endAngles == nil ? "2.circle" : "checkmark.circle.fill")
                        Text("Capture End Position")
                        Spacer()
                    }
                    .foregroundColor(endAngles == nil ? .primary : .green)
                }
                .buttonStyle(.bordered)
                .disabled(!hasValidPose)
                
                if let angles = endAngles {
                    anglesDisplay(angles, title: "End")
                        .font(.caption)
                }
            }
        }
    }
    
    private func anglesDisplay(_ angles: Angles, title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title) Position:")
                .fontWeight(.semibold)
            HStack {
                VStack(alignment: .leading) {
                    Text("L Hand: \(Int(angles.leftHand))°")
                    Text("R Hand: \(Int(angles.rightHand))°")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("L Leg: \(Int(angles.leftLeg))°")
                    Text("R Leg: \(Int(angles.rightLeg))°")
                }
            }
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var hasValidPose: Bool {
        !poseEstimator.bodyParts.isEmpty &&
        poseEstimator.bodyParts[.leftShoulder] != nil &&
        poseEstimator.bodyParts[.rightShoulder] != nil &&
        poseEstimator.bodyParts[.leftElbow] != nil &&
        poseEstimator.bodyParts[.rightElbow] != nil &&
        poseEstimator.bodyParts[.leftWrist] != nil &&
        poseEstimator.bodyParts[.rightWrist] != nil &&
        poseEstimator.bodyParts[.leftHip] != nil &&
        poseEstimator.bodyParts[.rightHip] != nil &&
        poseEstimator.bodyParts[.leftKnee] != nil &&
        poseEstimator.bodyParts[.rightKnee] != nil &&
        poseEstimator.bodyParts[.leftAnkle] != nil &&
        poseEstimator.bodyParts[.rightAnkle] != nil &&
        poseEstimator.bodyParts[.root] != nil &&
        poseEstimator.bodyParts[.neck] != nil &&
        poseEstimator.bodyParts[.nose] != nil
    }
    
    private var canSave: Bool {
        !name.isEmpty && startAngles != nil && endAngles != nil
    }
    
    private func captureStartPosition() {
        guard hasValidPose else { return }
        startAngles = calculateCurrentAngles()
    }
    
    private func captureEndPosition() {
        guard hasValidPose else { return }
        endAngles = calculateCurrentAngles()
    }
    
    private func calculateCurrentAngles() -> Angles {
        let bodyParts = poseEstimator.bodyParts
        
        let leftHandAngle = calculateAngle(
            p1: bodyParts[.leftElbow]!,
            p2: bodyParts[.leftShoulder]!,
            p3: bodyParts[.leftWrist]!
        )
        
        let rightHandAngle = calculateAngle(
            p1: bodyParts[.rightElbow]!,
            p2: bodyParts[.rightShoulder]!,
            p3: bodyParts[.rightWrist]!
        )
        
        let leftLegAngle = calculateAngle(
            p1: bodyParts[.leftKnee]!,
            p2: bodyParts[.leftHip]!,
            p3: bodyParts[.leftAnkle]!
        )
        
        let rightLegAngle = calculateAngle(
            p1: bodyParts[.rightKnee]!,
            p2: bodyParts[.rightHip]!,
            p3: bodyParts[.rightAnkle]!
        )
        
        return Angles(
            leftHand: leftHandAngle,
            rightHand: rightHandAngle,
            leftLeg: leftLegAngle,
            rightLeg: rightLegAngle
        )
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
    
    private func saveExercise() {
        guard let start = startAngles, let end = endAngles else {
            alertMessage = "Please capture both start and end positions"
            showAlert = true
            return
        }
        
        guard !name.isEmpty else {
            alertMessage = "Please enter an exercise name"
            showAlert = true
            return
        }
        
        if areTooSimilar(start, end) {
            alertMessage = "Start and end positions are too similar. Please choose more distinct positions."
            showAlert = true
            return
        }
        
        let customExercise = CustomExercise(
            name: name,
            startState: start,
            endState: end
        )
        
        let exercise = Exercise(
            name: name,
            type: .custom,
            requiredCount: repeatCount,
            customExercise: customExercise
        )
        
        modelContext.insert(exercise)
        try? modelContext.save()
        
        dismiss()
    }
    
    private func areTooSimilar(_ a1: Angles, _ a2: Angles) -> Bool {
        let threshold: CGFloat = 10
        return abs(a1.leftHand - a2.leftHand) < threshold &&
               abs(a1.rightHand - a2.rightHand) < threshold &&
               abs(a1.leftLeg - a2.leftLeg) < threshold &&
               abs(a1.rightLeg - a2.rightLeg) < threshold
    }
}
