//
//  ContentView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.10.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ExerciseListView()
                .onAppear {
                    DispatchQueue.main.async {
                        KeyboardWarmup.warmupInBackground()
                    }
                }
                .tabItem {
                    Label("Exercises", systemImage: "figure")
                }
            
            JoggingView()
                .tabItem {
                    Label("Jog", systemImage: "figure.run")
                }
            
            RoutesListView()
                .tabItem {
                    Label("Routes", systemImage: "map")
                }
        }
    }
}

#Preview {
    ContentView()
}
