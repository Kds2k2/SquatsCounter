//
//  ExercisePattern.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import Foundation
import SwiftData

struct PatternAngles: Codable, Equatable, Hashable {
    var leftHand: CGFloat?
    var rightHand: CGFloat?
    var leftLeg: CGFloat?
    var rightLeg: CGFloat?
}

@Model
final class ExercisePattern {
    var name: String

    var startState: PatternAngles
    var endState: PatternAngles
    
    var isSystem: Bool
    
    init(name: String, startState: PatternAngles, endState: PatternAngles, isSystem: Bool = false) {
        self.name = name
        self.startState = startState
        self.endState = endState
        self.isSystem = isSystem
    }
}

extension ExercisePattern {
    static func seedDefaultsIfNeeded(context: ModelContext) throws {
        let descriptor = FetchDescriptor<ExercisePattern>(
            predicate: #Predicate { $0.isSystem == true }
        )

        let existing = try context.fetch(descriptor)
        guard existing.isEmpty else { return } // already seeded

        let defaults: [ExercisePattern] = [
            ExercisePattern(
                name: "Squat",
                startState: PatternAngles(
                    leftHand: nil,
                    rightHand: nil,
                    leftLeg: 170,
                    rightLeg: 170
                ),
                endState: PatternAngles(
                    leftHand: nil,
                    rightHand: nil,
                    leftLeg: 100,
                    rightLeg: 100
                ),
                isSystem: true
            ),

            ExercisePattern(
                name: "Push-up",
                startState: PatternAngles(
                    leftHand: 160,
                    rightHand: 160,
                    leftLeg: nil,
                    rightLeg: nil
                ),
                endState: PatternAngles(
                    leftHand: 90,
                    rightHand: 90,
                    leftLeg: nil,
                    rightLeg: nil
                ),
                isSystem: true
            )
        ]

        defaults.forEach { context.insert($0) }
        try context.save()
    }
}
