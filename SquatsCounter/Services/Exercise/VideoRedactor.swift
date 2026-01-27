//
//  VideoRedactor.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 25.12.2025.
//

import SwiftUI
import AVFoundation
import Foundation
import Vision
import Combine

@MainActor
class VideoRedactor: NSObject, @MainActor AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var videoURL: URL?
    
    override init() {
        super.init()
    }
    
    //MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //TODO: ...
        LogManager.shared.debug("Start recording.")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        LogManager.shared.debug("didFinish.")
        if let error = error {
            LogManager.shared.error("Error recording: \(error.localizedDescription)")
          return
        }
  
        DispatchQueue.main.async {
            self.videoURL = outputFileURL
            LogManager.shared.debug("Video URL saved.")
        }
    }
}
