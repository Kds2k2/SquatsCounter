//
//  ExerciseCameraView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI

struct ExerciseCameraView: View {
    
    init(delegate: PoseEstimator) {
        self.delegate = delegate
        self.viewModel = .init(self.delegate)
    }
    
    var viewModel: ExerciseCameraViewModel
    var delegate: PoseEstimator
    
    var body: some View {
        ZStack {
            ExerciseCameraPreviewView(session: viewModel.captureSession)
                .onAppear {
                    Task {
                        viewModel.captureSession.startRunning()
                    }
                }
                .onDisappear {
                    Task {
                        viewModel.captureSession.stopRunning()
                    }
                }
        }
        .ignoresSafeArea()
    }
}
