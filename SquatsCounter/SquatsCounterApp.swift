//
//  SquatsCounterApp.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 08.10.2025.
//

import SwiftUI
import SwiftData

@main
struct SquatsCounterApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
    private let modelContainer = ModelContainer.make()
}
