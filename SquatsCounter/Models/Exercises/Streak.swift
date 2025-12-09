//
//  Streak.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 08.12.2025.
//

import SwiftData
import Foundation

@Model
final class Streak {
    var current: Int = 0
    var best: Int = 0
    var lastCompleted: Date? = nil
    
    init() {}
    
    func recordCompletion() {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent

        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let lastStart = lastCompleted.map { calendar.startOfDay(for: $0) }

        // Ignore duplicate completions within the same local day
        if let last = lastStart, last == todayStart {
            return
        }
        
        if let last = lastStart,
           let nextDay = calendar.date(byAdding: .day, value: 1, to: last),
           calendar.isDate(todayStart, inSameDayAs: nextDay) {
            current += 1
        } else {
            current = 1
        }
        
        if current > best { best = current }

        lastCompleted = now
    }
    
    func check() {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent

        let todayStart = calendar.startOfDay(for: .now)
        let lastStart = lastCompleted.map { calendar.startOfDay(for: $0) }

        if let last = lastStart,
           let nextDay = calendar.date(byAdding: .day, value: 1, to: last),
           !calendar.isDate(todayStart, inSameDayAs: nextDay) {
            current = 0
        }
    }
}
