//
//  StickFigureView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
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
                Stick(points: [rightAnkle.location, rightKnee.location, rightHip.location, root.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let leftAnkle = bodyParts[.leftAnkle],
               let leftKnee = bodyParts[.leftKnee],
               let leftHip = bodyParts[.leftHip],
               let root = bodyParts[.root] {
                Stick(points: [leftAnkle.location, leftKnee.location, leftHip.location, root.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let rightWrist = bodyParts[.rightWrist],
               let rightElbow = bodyParts[.rightElbow],
               let rightShoulder = bodyParts[.rightShoulder],
               let neck = bodyParts[.neck] {
                Stick(points: [rightWrist.location, rightElbow.location, rightShoulder.location, neck.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let leftWrist = bodyParts[.leftWrist],
               let leftElbow = bodyParts[.leftElbow],
               let leftShoulder = bodyParts[.leftShoulder],
               let neck = bodyParts[.neck] {
                Stick(points: [leftWrist.location, leftElbow.location, leftShoulder.location, neck.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
            
            if let root = bodyParts[.root],
               let neck = bodyParts[.neck],
               let nose = bodyParts[.nose] {
                Stick(points: [root.location, neck.location, nose.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
            }
        }
    }
}

extension StickFigureView {
    init(postEstimator: PoseEstimator, size: CGSize) {
        self.bodyParts = postEstimator.bodyParts
        self.size = size
    }
}
