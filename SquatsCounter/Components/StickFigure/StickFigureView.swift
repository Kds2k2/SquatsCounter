//
//  StickFigureView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//


import SwiftUI
import Vision

struct StickFigureView: View {
    var bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    var size: CGSize
    
    var body: some View {
        if !bodyParts.isEmpty {
            fullBodyView()
        }
    }
    
    private func fullBodyView() -> some View {
        ZStack {
            if let rightAnkle = bodyParts[.rightAnkle],
               let rightKnee = bodyParts[.rightKnee],
               let rightHip = bodyParts[.rightHip],
               let root = bodyParts[.root] {
                Stick(points: [rightAnkle, rightKnee, rightHip, root], size: size, name: "RL")
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let leftAnkle = bodyParts[.leftAnkle],
               let leftKnee = bodyParts[.leftKnee],
               let leftHip = bodyParts[.leftHip],
               let root = bodyParts[.root] {
                Stick(points: [leftAnkle, leftKnee, leftHip, root], size: size, name: "LL")
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let rightWrist = bodyParts[.rightWrist],
               let rightElbow = bodyParts[.rightElbow],
               let rightShoulder = bodyParts[.rightShoulder],
               let neck = bodyParts[.neck] {
                Stick(points: [rightWrist, rightElbow, rightShoulder, neck], size: size, name: "RH")
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let leftWrist = bodyParts[.leftWrist],
               let leftElbow = bodyParts[.leftElbow],
               let leftShoulder = bodyParts[.leftShoulder],
               let neck = bodyParts[.neck] {
                Stick(points: [leftWrist, leftElbow, leftShoulder, neck], size: size, name: "LH")
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let root = bodyParts[.root],
               let neck = bodyParts[.neck],
               let nose = bodyParts[.nose] {
                Stick(points: [root, neck, nose], size: size, name: "ROOT")
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
        }
    }
}

extension StickFigureView {
    init(delegate: PoseEstimator, size: CGSize) {
        self.bodyParts = delegate.bodyParts
        self.size = size
    }
}
