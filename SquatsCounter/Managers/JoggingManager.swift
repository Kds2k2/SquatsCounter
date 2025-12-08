//
//  LocationManager.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI
import CoreLocation

class JoggingManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var distance: Double = 0.0
    @Published var isStart: Bool = false
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var requiredDistance: Double = 5000.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        distance = 0.0
        lastLocation = nil
        routeCoordinates = []
        isStart = true
        locationManager.startUpdatingLocation()
    }
    
    func pause() {
        locationManager.stopUpdatingLocation()
    }
    
    func `continue`() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        isStart = false
        locationManager.stopUpdatingLocation()
        distance = 0.0
        lastLocation = nil
        routeCoordinates = []
    }

    func saveRoute() {
        guard !routeCoordinates.isEmpty else { return }

        let coords = routeCoordinates.map {
            Coordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        let route = JoggingRoute(date: .now, distance: distance, coordinates: coords)
        RouteStorage.shared.save(route)
    }
    
    func changeRequiredDistance(distance: Double) {
        requiredDistance = distance
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isStart, let newLocation = locations.last else { return }
        if let last = lastLocation {
            distance += newLocation.distance(from: last)
        }
        lastLocation = newLocation
        routeCoordinates.append(newLocation.coordinate)
        
        if distance >= requiredDistance {
            stop()
        }
    }
}
