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
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    @State private var showCongrats = false
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
            
            // BOTTOM
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black.opacity(0.8), Color.black.opacity(0.5), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 300)
                    
                    bottomView()
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
            Text("You ran " + joggingManager.distance.toKM)
        }
    }

    // swiftlint:disable function_body_length
    @ViewBuilder
    func bottomView() -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 10) {
                Button(action: {
                    //TODO: ...
                }) {
                    Text(AppString.Jogging.settings)
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
                    Text(AppString.Jogging.goal)
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
                        Text(AppString.Jogging.State.start)
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
                                Label(AppString.Jogging.State.stop, systemImage: AppImage.Jogging.stop)
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.gradient)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .cornerRadius(12)
                            }
                            .alert(AppString.Jogging.State.title, isPresented: $showStopAlert) {
                                Button(AppString.Jogging.State.discard, role: .destructive) {
                                    joggingManager.stop()
                                    isPause = false
                                    isStart = false
                                }
                                
                                Button(AppString.Jogging.State.save) {
                                    joggingManager.saveRoute()
                                    joggingManager.stop()
                                    isPause = false
                                    isStart = false
                                }

                                Button(AppString.Jogging.State.cancel, role: .cancel) { }
                                
                            } message: {
                                Text(AppString.Jogging.State.message)
                            }
                            
                            Button {
                                joggingManager.continue()
                                isPause = false
                            } label: {
                                Label(AppString.Jogging.State.continue, systemImage: AppImage.Jogging.continue)
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
                                Label(AppString.Jogging.State.pause, systemImage: AppImage.Jogging.pause)
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
