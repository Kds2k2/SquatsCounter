//
//  LocationManager.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    @Published var distance: Double = 0.0
    @Published var isJogging: Bool = false
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startJog() {
        distance = 0.0
        lastLocation = nil
        routeCoordinates = []
        isJogging = true
        locationManager.startUpdatingLocation()
    }
    
    func stopJog() {
        isJogging = false
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isJogging, let newLocation = locations.last else { return }
        if let last = lastLocation {
            distance += newLocation.distance(from: last)
        }
        lastLocation = newLocation
        routeCoordinates.append(newLocation.coordinate)
        
        if distance >= 5000 {
            stopJog()
        }
    }
}
