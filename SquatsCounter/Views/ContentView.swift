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
                .tabItem {
                    Label(AppString.Exercise.title, systemImage: "figure")
                }
                .onAppear {
                    DispatchQueue.main.async { KeyboardWarmup.warmupInBackground() }
                }
            
            JoggingView()
                .tabItem {
                    Label(AppString.Jogging.title, systemImage: "figure.run")
                }
            
            RoutesListView()
                .tabItem {
                    Label(AppString.Route.title, systemImage: "map")
                }
        }
    }
}

#Preview {
    ContentView()
}
