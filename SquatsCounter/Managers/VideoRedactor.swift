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

class VideoRedactor: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    @Published var videoURL: URL?
    
    override init() {
        super.init()
    }
    
    //MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //TODO: ...
        print("Start recording.")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("didFinish.")
        if let error = error {
          print("Error recording: \(error.localizedDescription)")
          return
        }
  
        DispatchQueue.main.async {
            self.videoURL = outputFileURL
            print("Video URL saved.")
        }
    }
}
