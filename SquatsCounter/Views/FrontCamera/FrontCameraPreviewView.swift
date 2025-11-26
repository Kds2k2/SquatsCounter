//
//  FrontCameraPreviewView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

struct FrontCameraPreviewView: UIViewRepresentable {
    var previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds
            }
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        NotificationCenter.default.removeObserver(self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
}
