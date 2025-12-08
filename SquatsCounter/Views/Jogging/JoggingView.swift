//
//  JoggingView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 23.10.2025.
//

import SwiftUI
import MapKit

struct JoggingView: View {
    
    @StateObject var joggingManager = JoggingManager()
    @State private var showCongrats = false
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var showSheet = true
    
    @State private var isStart = false
    @State private var isPause = false
    @State private var showStopAlert = false
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if joggingManager.routeCoordinates.count > 1 {
                    MapPolyline(coordinates: joggingManager.routeCoordinates)
                        .stroke(.blue, lineWidth: 4)
                }
                
                if let first = joggingManager.routeCoordinates.first {
                    Marker("Start", coordinate: first)
                }
                if let last = joggingManager.routeCoordinates.last {
                    Marker("You", coordinate: last)
                }
            }
            .mapStyle(.standard)
            .onChange(of: joggingManager.routeCoordinates.count) { _, _ in
                if let last = joggingManager.routeCoordinates.last {
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
        .onChange(of: joggingManager.distance) { old, new in
            if new >= 5000 {
                joggingManager.stop()
                joggingManager.saveRoute()
                showCongrats = true
            }
        }
        .alert("🎉 Congratulations!", isPresented: $showCongrats) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You ran \(joggingManager.distance / 1000, specifier: "%.2f") km")
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
            
            HStack {
                if !isStart {
                    Button(action: {
                        joggingManager.start()
                        isStart = true
                    }) {
                        Text("Start")
                            .foregroundStyle(AppColors.background)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding(15)
                            .background(AppColors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                } else {
                    HStack {
                        if isPause {
                            Button {
                                showStopAlert = true
                            } label: {
                                Label("Stop", systemImage: "stop.circle.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                            .alert("End Jog?", isPresented: $showStopAlert) {
                                Button("Discard", role: .destructive) {
                                    joggingManager.stop()
                                    isPause = false
                                    isStart = false
                                }
                                
                                Button("Save") {
                                    joggingManager.saveRoute()
                                    joggingManager.stop()
                                    isPause = false
                                    isStart = false
                                }

                                Button("Cancel", role: .cancel) { }
                                
                            } message: {
                                Text("Do you want to save this route or discard it?")
                            }
                            
                            Button {
                                joggingManager.continue()
                                isPause = false
                            } label: {
                                Label("Continue", systemImage: "play.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button {
                                joggingManager.pause()
                                isPause = true
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.yellow.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                        }
                    }

                }
            }
        }
        .padding(.horizontal, 15)
        .safeAreaPadding(.bottom)
    }
}

#Preview {
    JoggingView()
}
