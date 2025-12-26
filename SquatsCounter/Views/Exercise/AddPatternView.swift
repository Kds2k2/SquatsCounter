//
//  AddPatternView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 24.12.2025.
//

import SwiftUI
import SwiftData

struct AddPatternView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var videoRedactor: VideoRedactor
    @State var isReviewing: Bool = false
    @State var videoURL: URL?
    
    init() {
        _videoRedactor = StateObject(wrappedValue: VideoRedactor())
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                GeometryReader { geo in
                    if isReviewing {
                        Text("hihiahha")
                    } else {
                        VideoRecorderView(videoRedactor: videoRedactor)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    }
                }
            }
            .ignoresSafeArea()
            .toolbar(.hidden, for: .tabBar)
            .onReceive(videoRedactor.$videoURL) { newURL in
                if let newURL = newURL {
                    LogManager.shared.debug("Video URL: \(newURL.absoluteString);")
                    isReviewing = true
                } else {
                    LogManager.shared.error("Video URL is null.")
                }
            }
        }
    }
}
