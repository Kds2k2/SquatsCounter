//
//  Workout.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 23.12.2025.
//

import SwiftUI
import SwiftData

@Model
final class Workout: ObservableObject {
    var name: String
    
    var repeats: Int = 0
    var restDuration: Int = 2
    
    var isStart: Bool = false
    var isDone: Bool = false
    var lastRefresh: Date? = nil
    
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise]?
    
    @Relationship(deleteRule: .cascade)
    var streak: Streak?
    
    init(name: String, repeats: Int, restDuration: Int, exercises: [Exercise]) {
        self.name = name
        self.repeats = repeats
        self.restDuration = restDuration
        self.lastRefresh = .now
        self.exercises = []
        self.streak = Streak()
    }
    
    func refresh() {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent

        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let lastStart = lastRefresh.map { calendar.startOfDay(for: $0) }

        if lastStart != todayStart {
            isStart = false
            isDone = false
            lastRefresh = now
            streak?.check()
        }
    }
}
