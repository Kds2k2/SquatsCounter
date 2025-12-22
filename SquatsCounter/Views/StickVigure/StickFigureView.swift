//
//  StickFigureView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI

struct StickFigureView: View {
    @ObservedObject var postEstimator: PoseEstimator
    var size: CGSize
    var exercise: ExerciseType = .squating
    
    var body: some View {
        if !postEstimator.bodyParts.isEmpty {
            switch exercise {
            case .pushUps:
                pushUpsView()
            case .squating:
                squatingView()
            case .custom:
                fullBodyView()
            }
        }
    }
    
    private func pushUpsView() -> some View {
        ZStack {
            // Right arm
            Stick(points: [postEstimator.bodyParts[.rightWrist]!.location, postEstimator.bodyParts[.rightElbow]!.location, postEstimator.bodyParts[.rightShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Left arm
            Stick(points: [postEstimator.bodyParts[.leftWrist]!.location, postEstimator.bodyParts[.leftElbow]!.location, postEstimator.bodyParts[.leftShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
        }
    }
    
    private func squatingView() -> some View {
        ZStack {
            // Right leg
            Stick(points: [postEstimator.bodyParts[.rightAnkle]!.location, postEstimator.bodyParts[.rightKnee]!.location, postEstimator.bodyParts[.rightHip]!.location, postEstimator.bodyParts[.root]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Left leg
            Stick(points: [postEstimator.bodyParts[.leftAnkle]!.location, postEstimator.bodyParts[.leftKnee]!.location, postEstimator.bodyParts[.leftHip]!.location, postEstimator.bodyParts[.root]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Right arm
            Stick(points: [postEstimator.bodyParts[.rightWrist]!.location, postEstimator.bodyParts[.rightElbow]!.location, postEstimator.bodyParts[.rightShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Left arm
            Stick(points: [postEstimator.bodyParts[.leftWrist]!.location, postEstimator.bodyParts[.leftElbow]!.location, postEstimator.bodyParts[.leftShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Root to nose
            Stick(points: [postEstimator.bodyParts[.root]!.location, postEstimator.bodyParts[.neck]!.location,  postEstimator.bodyParts[.nose]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
        }
    }
    
    private func fullBodyView() -> some View {
        ZStack {
            // Right leg
            Stick(points: [postEstimator.bodyParts[.rightAnkle]!.location, postEstimator.bodyParts[.rightKnee]!.location, postEstimator.bodyParts[.rightHip]!.location, postEstimator.bodyParts[.root]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Left leg
            Stick(points: [postEstimator.bodyParts[.leftAnkle]!.location, postEstimator.bodyParts[.leftKnee]!.location, postEstimator.bodyParts[.leftHip]!.location, postEstimator.bodyParts[.root]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Right arm
            Stick(points: [postEstimator.bodyParts[.rightWrist]!.location, postEstimator.bodyParts[.rightElbow]!.location, postEstimator.bodyParts[.rightShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Left arm
            Stick(points: [postEstimator.bodyParts[.leftWrist]!.location, postEstimator.bodyParts[.leftElbow]!.location, postEstimator.bodyParts[.leftShoulder]!.location, postEstimator.bodyParts[.neck]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
            
            // Root to nose
            Stick(points: [postEstimator.bodyParts[.root]!.location, postEstimator.bodyParts[.neck]!.location,  postEstimator.bodyParts[.nose]!.location], size: size)
                .stroke(lineWidth: 5.0)
                .fill(Color.green)
        }
    }
}
