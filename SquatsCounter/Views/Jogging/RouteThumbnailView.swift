//
//  RouteThumbnailView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 28.12.2025.
//

import SwiftUI

struct RouteThumbnailView: View {
    let route: JoggingRoute

    var body: some View {
        Canvas { context, size in
            let points = route.coordinates.normalizedPoints(in: size, inset: 14)

            guard let first = points.first else { return }

            var path = Path()
            path.move(to: first)
            for p in points.dropFirst() {
                path.addLine(to: p)
            }

            context.stroke(path, with: .color(.blue), lineWidth: 2)
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
        )
    }
}
