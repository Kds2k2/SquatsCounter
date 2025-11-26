//
//  Exercise.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 13.10.2025.
//

import SwiftUI
import SwiftData

@Model
final class Exercise: ObservableObject {
    var name: String
    
    var type: ExerciseType
    
    var count: Int = 0
    var requiredCount: Int
    
    var isDone: Bool = false
    var isDoneDate: Date? = nil
    
    init(name: String, type: ExerciseType, requiredCount: Int) {
        self.name = name
        self.type = type
        self.requiredCount = requiredCount
    }
}
