//
//  RoutesListView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.11.2025.
//

import SwiftUI

struct RoutesListView: View {
    @ObservedObject private var storage = RouteStorage.shared
    @State private var selectedRoute: JoggingRoute?

    var body: some View {
        NavigationStack {
            List(storage.routes.sorted(by: { $0.date > $1.date })) { route in
                Button {
                    selectedRoute = route
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(route.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        
                        Text("Distance: \(route.distance / 1000, specifier: "%.2f") km")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Your Routes")
            .sheet(item: $selectedRoute) { route in
                RouteDetailView(route: route)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
