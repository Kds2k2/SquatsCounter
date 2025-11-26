//
//  Coordinate2D.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import CoreLocation

struct Coordinate2D: Codable {
    let latitude: Double
    let longitude: Double
    var cLLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

extension Array where Element == Coordinate2D {
    func toCLLocationCoordinate2D() -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        for element in self {
            coordinates.append(element.cLLocationCoordinate2D)
        }
        return coordinates
    }
}
