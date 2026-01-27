//
//  VideoRecorderView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 24.12.2025.
//

import SwiftUI
import Combine

@MainActor
struct VideoRecorderView: View {
    
    @ObservedObject var viewModel: VideoRecorderViewModel
    var videoRedactor: VideoRedactor
    
    init(videoRedactor: VideoRedactor) {
        self.videoRedactor = videoRedactor
        self.viewModel = .init(self.videoRedactor)
    }
    
    var body: some View {
        ZStack {
            VideoRecorderPreviewView(previewLayer: viewModel.frontPreviewLayer)
                .onAppear {
                    LogManager.shared.debug("Task to start running.")
                    Task {
                        viewModel.captureSession.startRunning()
                    }
                }
                .onDisappear {
                    LogManager.shared.debug("Task to stop running.")
                    Task {
                        viewModel.captureSession.stopRunning()
                    }
                }
            
            VStack {
                Spacer()
                recordButton
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isRecording {
                ToolbarItem(placement: .principal) {
                    Text("Recording")
                        .font(.subheadline.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var recordButton: some View {
        Button {
            viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 72, height: 72)

                Circle()
                    .fill(viewModel.isRecording ? .red : .white)
                    .frame(
                        width: viewModel.isRecording ? 32 : 56,
                        height: viewModel.isRecording ? 32 : 56
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isRecording)
            }
        }
        .padding(.bottom, 30)
    }
}

