//
//  ModelContainer+make.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 17.10.2025.
//

import Foundation
import SwiftUI
import SwiftData

extension ModelContainer {
    @MainActor static func make(fileManager: FileManager = .default) -> ModelContainer {
        let schema = Schema([ Exercise.self, Streak.self, Quest.self ])
        let cfg = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        print("Located at \(cfg.url.path(percentEncoded: false))")
        
        do {
            let container = try ModelContainer(for: schema, configurations: [ cfg ])
            container.mainContext.autosaveEnabled = true
            return container
        } catch {
            fatalError("Could not create Model Container: \(error)")
        }
    }
}
