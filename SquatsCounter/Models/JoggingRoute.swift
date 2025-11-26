//
//  JoggingRoute.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI
import CoreLocation

struct JoggingRoute: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let distance: Double
    let coordinates: [Coordinate2D]
}
