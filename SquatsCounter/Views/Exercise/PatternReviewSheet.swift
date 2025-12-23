//
//  PatternReviewSheet.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 23.12.2025.
//

import SwiftUI

struct PatternReviewSheet: View {
    @Binding var name: String
    @Binding var startTime: Double?
    @Binding var endTime: Double?
    @Binding var currentTime: Double
    
    let videoURL: URL
    let videoDuration: Double
    let onSeek: (Double) -> Void
    let onSave: () -> Void
    let canSave: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VideoTimelineView(
                    videoURL: videoURL,
                    videoDuration: videoDuration,
                    startTime: $startTime,
                    endTime: $endTime,
                    currentTime: $currentTime,
                    onSeek: onSeek
                )
                
                Divider()
                
                VStack(spacing: 12) {
                    TextField("Pattern name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Set start and end times to define the movement pattern")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Review Pattern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
