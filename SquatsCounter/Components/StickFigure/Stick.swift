//
//  Stick.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//

@preconcurrency import Vision
import SwiftUI

struct Stick: Shape {
    var points: [VNRecognizedPoint]
    var size: CGSize
    var name: String

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let validPoints = points.filter { $0.confidence > 0.2 }
        let cgPoints = validPoints.map { convert($0, size: size) }

        guard let first = cgPoints.first else { return path }

        path.move(to: first)
        for point in cgPoints.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }

    private func convert(_ point: VNRecognizedPoint, size: CGSize) -> CGPoint {
        CGPoint(
            x: point.location.x * size.width,
            y: (1 - point.location.y) * size.height
        )
    }
}
