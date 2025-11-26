//
//  FrontCameraView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI

struct FrontCameraView: View {
    
    init(poseEstimator: PoseEstimator) {
        self.poseEstimator = poseEstimator
        self.viewModel = .init(self.poseEstimator)
    }
    
    @ObservedObject var viewModel: FrontContentViewModel
    var poseEstimator: PoseEstimator
    
    var body: some View {
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
        }
        .ignoresSafeArea()
    }
}
