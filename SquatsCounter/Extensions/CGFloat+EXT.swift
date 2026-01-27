//
//  CGFloat+cgImageOrientation.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.10.2025.
//

import Foundation
import Vision

extension CGFloat {
    var cgImageOrientation: CGImagePropertyOrientation {
        switch Int(self) {
        case 90:
            return .up
        case 0:
            return .right
        case 180:
            return .leftMirrored
        default:
            return .right
        }
    }
}
