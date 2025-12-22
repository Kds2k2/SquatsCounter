//
//  ExerciseType.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import Foundation

enum ExerciseType: Codable, Identifiable, Comparable, Hashable {
    case pushUps
    case squating
    case custom(CustomExercise)

    var id: String {
        switch self {
        case .pushUps:
            return "pushUps"
        case .squating:
            return "squating"
        case .custom(let exercise):
            return "custom-\(exercise.id)"
        }
    }

    static func < (lhs: ExerciseType, rhs: ExerciseType) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    private var sortOrder: Int {
        switch self {
        case .pushUps: return 0
        case .squating: return 1
        case .custom: return 2
        }
    }
}

struct CustomExercise: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String

    var startState: Angles
    var endState: Angles
}

struct Angles: Codable, Equatable, Hashable {
    var leftHand: CGFloat
    var rightHand: CGFloat
    var leftLeg: CGFloat
    var rightLeg: CGFloat
}
