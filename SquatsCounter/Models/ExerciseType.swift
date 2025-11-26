//
//  ExerciseType.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

enum ExerciseType: String, Codable, Comparable, CaseIterable, Identifiable {
    case pushUps = "PushUps"
    case squating = "Squating"
    
    var id: String { rawValue }
    
    static func < (lhs: ExerciseType, rhs: ExerciseType) -> Bool {
        return lhs.id == rhs.id
    }
}
