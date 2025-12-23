//
//  PoseEstimator.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI
import AVFoundation
import Foundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    
    private let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint] = [:]
    @Published var count: Int = 0
    
    private var exercisePattern: ExercisePattern
    
    private var wasInEndState = false
    private var subscriptions = Set<AnyCancellable>()
    public var isPaused = false
    
    init(exercisePattern: ExercisePattern) {
        self.exercisePattern = exercisePattern
        super.init()
        setupSubscription()
    }
    
    private func setupSubscription() {
        subscriptions.removeAll()
        
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { [weak self] bodyParts in
                guard let self = self else { return }
                self.count(bodyParts: bodyParts)
            })
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let request = VNDetectHumanBodyPoseRequest(completionHandler: handler)
        
        do {
            try sequenceHandler.perform([request], on: sampleBuffer, orientation: .up)
        } catch {
            print("Some error: \(error.localizedDescription)")
        }
    }
    
    func handler(request: VNRequest, error: Error?) {
        guard error == nil else {
            print("Some error: \(error!.localizedDescription)")
            return
        }
        
        guard !isPaused else { return }
        
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation] else {
            print("Body pose results == nil")
            return
        }
        
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else {
            print("Body parts == nil")
            return
        }
        
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    //push up: 90, 160
    //squating: 140, 160
    func count(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        let tolerance: CGFloat = 5

        guard
            // R HAND
            let rightShoulder = bodyParts[.rightShoulder],
            let rightElbow = bodyParts[.rightElbow],
            let rightWrist = bodyParts[.rightWrist],

            // L HAND
            let leftShoulder = bodyParts[.leftShoulder],
            let leftElbow = bodyParts[.leftElbow],
            let leftWrist = bodyParts[.leftWrist],

            // R LEG
            let rightHip = bodyParts[.rightHip],
            let rightKnee = bodyParts[.rightKnee],
            let rightAnkle = bodyParts[.rightAnkle],

            // L LEG
            let leftHip = bodyParts[.leftHip],
            let leftKnee = bodyParts[.leftKnee],
            let leftAnkle = bodyParts[.leftAnkle]
        else { return }

        let current = PatternAngles(
            leftHand: calculateAngel(
                vPoint1: leftElbow,
                vPoint2: leftShoulder,
                vPoint3: leftWrist
            ),
            rightHand: calculateAngel(
                vPoint1: rightElbow,
                vPoint2: rightShoulder,
                vPoint3: rightWrist
            ),
            leftLeg: calculateAngel(
                vPoint1: leftKnee,
                vPoint2: leftHip,
                vPoint3: leftAnkle
            ),
            rightLeg: calculateAngel(
                vPoint1: rightKnee,
                vPoint2: rightHip,
                vPoint3: rightAnkle
            )
        )

        let isAtEndState =
            isLess(current.rightHand, than: exercisePattern.endState.rightHand, tolerance: tolerance) &&
            isLess(current.leftHand,  than: exercisePattern.endState.leftHand,  tolerance: tolerance) &&
            isLess(current.rightLeg,  than: exercisePattern.endState.rightLeg,  tolerance: tolerance) &&
            isLess(current.leftLeg,   than: exercisePattern.endState.leftLeg,   tolerance: tolerance)

        if isAtEndState {
            wasInEndState = true
            return
        }

        let isAtStartState =
            isGreater(current.rightHand, than: exercisePattern.startState.rightHand, tolerance: tolerance) &&
            isGreater(current.leftHand,  than: exercisePattern.startState.leftHand,  tolerance: tolerance) &&
            isGreater(current.rightLeg,  than: exercisePattern.startState.rightLeg,  tolerance: tolerance) &&
            isGreater(current.leftLeg,   than: exercisePattern.startState.leftLeg,   tolerance: tolerance)

        if isAtStartState && wasInEndState {
            count += 1
            wasInEndState = false
            print("✅ CUSTOM EXERCISE COUNT: \(count)")
        }
    }

    private func calculateAngel(vPoint1: VNRecognizedPoint, vPoint2: VNRecognizedPoint, vPoint3: VNRecognizedPoint) -> CGFloat {
        let point1 = CGPoint(x: vPoint1.location.x, y: 1 - vPoint1.location.y)
        let point2 = CGPoint(x: vPoint2.location.x, y: 1 - vPoint2.location.y)
        let point3 = CGPoint(x: vPoint3.location.x, y: 1 - vPoint3.location.y)
        
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
    
    @inline(__always)
    func isLess(_ current: CGFloat?, than target: CGFloat?, tolerance: CGFloat) -> Bool {
        guard let target else { return true }
        guard let current else { return false }
        return current < target + tolerance
    }

    @inline(__always)
    func isGreater(_ current: CGFloat?, than target: CGFloat?, tolerance: CGFloat) -> Bool {
        guard let target else { return true }
        guard let current else { return false }
        return current > target - tolerance
    }
}
