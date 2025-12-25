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
    
    var count: Int = 0
    var requiredCount: Int
    
    var isStart: Bool = false
    var isDone: Bool = false
    var lastRefresh: Date? = nil
    
    @Relationship(deleteRule: .nullify)
    var pattern: ExercisePattern?
    
    @Relationship(deleteRule: .cascade)
    var streak: Streak
    
    init(name: String, pattern: ExercisePattern, requiredCount: Int) {
        self.name = name
        self.requiredCount = requiredCount
        self.lastRefresh = .now
        
        self.pattern = pattern
        self.streak = Streak()
    }
    
    func refresh() {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent

        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let lastStart = lastRefresh.map { calendar.startOfDay(for: $0) }

        if lastStart != todayStart {
            count = 0
            isStart = false
            isDone = false
            lastRefresh = now
            streak.check()
        }
    }
}
