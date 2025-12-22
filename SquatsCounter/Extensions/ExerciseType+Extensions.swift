//
//  ExerciseType+Extensions.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 22.12.2025.
//

import Foundation

extension ExerciseType: CaseIterable {
    static var allCases: [ExerciseType] {
        [.pushUps, .squating]
    }
    
    var rawValue: String {
        switch self {
        case .pushUps:
            return "Push-ups"
        case .squating:
            return "Squats"
        case .custom(let exercise):
            return exercise.name
        }
    }
}
