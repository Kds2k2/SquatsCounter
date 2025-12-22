//
//  VideoTimelineView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import SwiftUI
import AVFoundation

struct VideoTimelineView: View {
    let videoURL: URL
    let videoDuration: Double
    @Binding var startTime: Double?
    @Binding var endTime: Double?
    @Binding var currentTime: Double
    
    let onSeek: (Double) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Duration: \(formatTime(videoDuration))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)
                    .cornerRadius(8)
                
                if let start = startTime {
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 4)
                        .offset(x: CGFloat(start / videoDuration) * UIScreen.main.bounds.width * 0.85)
                }
                
                if let end = endTime {
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 4)
                        .offset(x: CGFloat(end / videoDuration) * UIScreen.main.bounds.width * 0.85)
                }
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2)
                    .offset(x: CGFloat(currentTime / videoDuration) * UIScreen.main.bounds.width * 0.85)
            }
            .frame(height: 60)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let width = UIScreen.main.bounds.width * 0.85
                        let time = Double(value.location.x / width) * videoDuration
                        let clampedTime = max(0, min(videoDuration, time))
                        currentTime = clampedTime
                        onSeek(clampedTime)
                    }
            )
            
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .monospacedDigit()
                Spacer()
                Text(formatTime(videoDuration))
                    .font(.caption)
                    .monospacedDigit()
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    startTime = currentTime
                }) {
                    HStack {
                        Image(systemName: startTime == nil ? "1.circle" : "checkmark.circle.fill")
                        Text("Set Start")
                        if let start = startTime {
                            Text("(\(formatTime(start)))")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(startTime == nil ? .primary : .green)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    endTime = currentTime
                }) {
                    HStack {
                        Image(systemName: endTime == nil ? "2.circle" : "checkmark.circle.fill")
                        Text("Set End")
                        if let end = endTime {
                            Text("(\(formatTime(end)))")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(endTime == nil ? .primary : .red)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
