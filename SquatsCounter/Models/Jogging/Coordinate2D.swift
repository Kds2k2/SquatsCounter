//
//  Coordinate2D.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import Swift
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

extension Array where Element == Coordinate2D {

    func normalizedPoints(in size: CGSize, inset: CGFloat = 10) -> [CGPoint] {
        guard count > 1 else { return [] }

        let lats = map(\.latitude)
        let lons = map(\.longitude)

        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!

        let latRange = maxLat - minLat
        let lonRange = maxLon - minLon
        let scale = Swift.max(latRange, lonRange)

        let drawWidth = size.width - inset * 2
        let drawHeight = size.height - inset * 2

        return map { coord in
            let x = (coord.longitude - minLon) / scale
            let y = (coord.latitude - minLat) / scale

            return CGPoint(
                x: inset + x * drawWidth,
                y: inset + (drawHeight - y * drawHeight)
            )
        }
    }
}

