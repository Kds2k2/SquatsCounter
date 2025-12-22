//
//  ExerciseType.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import Foundation
import SwiftData

enum ExerciseType: String, Codable, Identifiable, Comparable, Hashable {
    case pushUps
    case squating
    case custom

    var id: String {
        return self.rawValue
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

@Model
final class CustomExercise {
    var id: UUID = UUID()
    var name: String

    var startState: Angles
    var endState: Angles
    
    @Relationship(inverse: \Exercise.customExercise)
    var exercise: Exercise?
    
    init(name: String, startState: Angles, endState: Angles) {
        self.id = UUID()
        self.name = name
        self.startState = startState
        self.endState = endState
    }
}

struct Angles: Codable, Equatable, Hashable {
    var leftHand: CGFloat
    var rightHand: CGFloat
    var leftLeg: CGFloat
    var rightLeg: CGFloat
}
