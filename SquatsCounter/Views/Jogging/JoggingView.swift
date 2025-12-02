//
//  JoggingView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 23.10.2025.
//

import SwiftUI
import MapKit

struct JoggingView: View {
    
    @StateObject var locationManager = LocationManager()
    @State private var showCongrats = false
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var showSheet = true
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if locationManager.routeCoordinates.count > 1 {
                    MapPolyline(coordinates: locationManager.routeCoordinates)
                        .stroke(.blue, lineWidth: 4)
                }
                
                if let first = locationManager.routeCoordinates.first {
                    Marker("Start", coordinate: first)
                }
                if let last = locationManager.routeCoordinates.last {
                    Marker("You", coordinate: last)
                }
            }
            .mapStyle(.standard)
            .onChange(of: locationManager.routeCoordinates.count) { _, _ in
                if let last = locationManager.routeCoordinates.last {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: last,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            )
                        )
                    }
                }
            }
            
            //Bottom
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black.opacity(0.8), Color.black.opacity(0.5), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 300)
                    
                    BottomView()
                }
            }
        }
        .onChange(of: locationManager.distance) { old, new in
            if new >= 5000 {
                locationManager.stopJog()
                saveRoute()
                showCongrats = true
            }
        }
        .alert("🎉 Congratulations!", isPresented: $showCongrats) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You ran \(locationManager.distance / 1000, specifier: "%.2f") km")
        }
    }

    @ViewBuilder
    func BottomView() -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Button(action: {
                    //TODO: ...
                }) {
                    Text("Settings")
                        .foregroundStyle(AppColors.textPrimary)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 25)
                        .padding(10)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .glassEffect(.clear)
                }
                
                Button(action: {
                    //TODO: ...
                }) {
                    Text("Goal")
                        .foregroundStyle(AppColors.textPrimary)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 25)
                        .padding(10)
                        .background(Color(.primary).opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .glassEffect(.clear)
                }
            }
            
            Button(action: {
                if locationManager.isJogging {
                    locationManager.stopJog()
                    saveRoute()
                } else {
                    locationManager.startJog()
                }
            }) {
                Text(locationManager.isJogging ? "Stop Jog" : "Start Jog")
                    .foregroundStyle(AppColors.background)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .padding(15)
                    .background(AppColors.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
        }
        .padding(.horizontal, 15)
        .safeAreaPadding(.bottom)
    }
    
    private func saveRoute() {
        guard !locationManager.routeCoordinates.isEmpty else { return }

        let coords = locationManager.routeCoordinates.map {
            Coordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        let route = JoggingRoute(date: .now, distance: locationManager.distance, coordinates: coords)
        RouteStorage.shared.save(route)
    }
}

#Preview {
    JoggingView()
}

//.sheet(isPresented: $showSheet) {
//    VStack(spacing: 20) {
//        HStack {
//            Text("Activity Info")
//                .font(.title2)
//                .foregroundStyle(Color(.textPrimary))
//            
//            Spacer()
//            
//            Button {
//                //Dismiss
//            } label: {
//                Image(systemName: "xmark")
//                    .font(.system(size: 24, weight: .regular))
//                    .foregroundStyle(Color(.textPrimary))
//            }
//            .padding(10)
//            .background(.ultraThinMaterial)
//            .background(Color(.primary).opacity(0.25))
//            .clipShape(Circle())
//        }
//        .padding([.top], 15)
//        
//        HStack {
//            Spacer()
//            
//            VStack {
//                Text("\(locationManager.distance / 1000, specifier: "%.2f") km")
//                    .font(.title2)
//                    .foregroundStyle(Color(.textPrimary))
//            }
//            .padding(10)
//            .background(.ultraThinMaterial)
//            .background(Color(.primary).opacity(0.25))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//            Spacer()
//            
//            VStack {
//                Text("\(locationManager.distance / 1000, specifier: "%.2f") cal")
//                    .font(.title2)
//                    .foregroundStyle(Color(.textPrimary))
//            }
//            .padding(10)
//            .background(.ultraThinMaterial)
//            .background(Color(.primary).opacity(0.25))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            
//            Spacer()
//        }
//        
//        Button(locationManager.isJogging ? "Stop Jog" : "Start Jog") {
//            if locationManager.isJogging {
//                locationManager.stopJog()
//                saveRoute()
//            } else {
//                locationManager.startJog()
//            }
//        }
//        .foregroundStyle(Color(.textPrimary))
//        .font(.system(size: 18, weight: .semibold))
//        .frame(maxWidth: .infinity)
//        .frame(height: 30)
//        .padding(10)
//        .background(.ultraThinMaterial)
//        .background(Color(.primary).opacity(0.25))
//        .clipShape(RoundedRectangle(cornerRadius: 30))
//    }
//    .padding()
//    .presentationDetents([.fraction(0.25)])
//    .presentationDragIndicator(.visible)
//}
