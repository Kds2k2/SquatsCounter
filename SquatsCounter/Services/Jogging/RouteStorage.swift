//
//  RouteStorage.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI
import Combine

@MainActor
final class RouteStorage: ObservableObject {
    static let shared = RouteStorage()
    @Published private(set) var routes: [JoggingRoute] = []
    
    private let filename = "saved_routes.json"
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    private init() { load() }

    func save(_ route: JoggingRoute) {
        routes.append(route)
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(routes)
            try data.write(to: fileURL)
        } catch {
            LogManager.shared.error("Failed to save routes: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            routes = try JSONDecoder().decode([JoggingRoute].self, from: data)
        } catch {
            LogManager.shared.error("Failed to load routes: \(error)")
        }
    }
}
