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
    
    private var type: ExerciseType = .pushUps
    
    private var wasInBottomPosition = false
    private var subscriptions = Set<AnyCancellable>()
    public var isPaused = false
    
    init(type: ExerciseType = .pushUps, count: Int = 0) {
        self.type = type
        super.init()
        setupSubscription()
    }
    
    private func setupSubscription() {
        subscriptions.removeAll()
        
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { [weak self] bodyParts in
                guard let self = self else { return }
                switch self.type {
                case .pushUps:
                    self.countPushUps(bodyParts: bodyParts)
                case .squating:
                    self.countSquats(bodyParts: bodyParts)
                }
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
            //print("Body parts == nil")
            return
        }
        
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func countSquats(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        //POINTS
        guard
            let rightKnee = bodyParts[.rightKnee],
            let rightHip = bodyParts[.rightHip],
            let rightAnkle = bodyParts[.rightAnkle],
            let leftKnee = bodyParts[.leftKnee],
            let leftHip = bodyParts[.leftHip],
            let leftAnkle = bodyParts[.leftAnkle]
        else { return }
        
        // ANGLES
        let rightAngle = calculateAngel(vPoint1: rightKnee, vPoint2: rightHip, vPoint3: rightAnkle)
        let leftAngle = calculateAngel(vPoint1: leftKnee, vPoint2: leftHip, vPoint3: leftAnkle)
        
        if rightAngle < 140 && leftAngle < 140 {
            wasInBottomPosition = true
        } else if rightAngle > 160 && leftAngle > 160 && wasInBottomPosition {
            count += 1
            wasInBottomPosition = false
            print("✅ Squat \(count)")
        }
    }
    
    func countPushUps(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        //POINTS
        guard
            let rightShoulder = bodyParts[.rightShoulder],
            let rightElbow = bodyParts[.rightElbow],
            let rightWrist = bodyParts[.rightWrist],
            let leftShoulder = bodyParts[.leftShoulder],
            let leftElbow = bodyParts[.leftElbow],
            let leftWrist = bodyParts[.leftWrist]
        else { return }
        
        // ANGLES
        let rightAngle = calculateAngel(vPoint1: rightElbow, vPoint2: rightShoulder, vPoint3: rightWrist)
        let leftAngle = calculateAngel(vPoint1: leftElbow, vPoint2: leftShoulder, vPoint3: leftWrist)
        
        if rightAngle < 90 && leftAngle < 90 {
            wasInBottomPosition = true
        } else if rightAngle > 160 && leftAngle > 160 && wasInBottomPosition {
            count += 1
            wasInBottomPosition = false
            print("✅ Push-up \(count)")
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
    
    func changeType(_ newType: ExerciseType) {
        self.type = newType
        wasInBottomPosition = false
        setupSubscription()
        
        print("Changed exercise type to: \(newType.rawValue)")
    }
}
