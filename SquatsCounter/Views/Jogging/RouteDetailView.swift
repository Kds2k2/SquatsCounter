//
//  RouteDetailView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: JoggingRoute
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            MapPolyline(coordinates: route.coordinates.toCLLocationCoordinate2D())
                .stroke(.blue, lineWidth: 3)
            
            if let start = route.coordinates.first?.cLLocationCoordinate2D {
                Marker("Start", coordinate: start).tint(.green)
            }
            
            if let end = route.coordinates.last?.cLLocationCoordinate2D {
                Marker("End", coordinate: end).tint(.red)
            }
        }
        .onAppear {
            if let center = route.coordinates.first?.cLLocationCoordinate2D {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: center,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Route Details")
    }
}
