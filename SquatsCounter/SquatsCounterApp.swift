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
    private let modelContainer = ModelContainer.make()
    
    init() {
        //Check normal init for DB.
        //try? modelContainer.erase()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
    
}
