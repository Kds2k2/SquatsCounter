//
//  ExercisePattern.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import Foundation
import SwiftData

@Model
final class ExercisePattern {
    var name: String

    var startState: PatternAngles
    var endState: PatternAngles
    
    init(name: String, startState: PatternAngles, endState: PatternAngles) {
        self.name = name
        self.startState = startState
        self.endState = endState
    }
}

struct PatternAngles: Codable, Equatable, Hashable {
    var leftHand: CGFloat?
    var rightHand: CGFloat?
    var leftLeg: CGFloat?
    var rightLeg: CGFloat?
}
