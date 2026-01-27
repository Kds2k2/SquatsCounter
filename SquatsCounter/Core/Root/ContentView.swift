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
                .tabItem { Label(AppString.TabBar.exercise, systemImage: AppImage.TabBar.exercise) }
                .onAppear { DispatchQueue.main.async { KeyboardWarmup.warmupInBackground() }}
            
            JoggingView()
                .tabItem { Label(AppString.TabBar.jogging, systemImage: AppImage.TabBar.jogging)}
            
            RoutesListView()
                .tabItem { Label(AppString.TabBar.routes, systemImage: AppImage.TabBar.routes)}
        }
    }
}

#Preview {
    ContentView()
}
