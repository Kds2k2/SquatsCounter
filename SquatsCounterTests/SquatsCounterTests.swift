//
//  SquatsCounterTests.swift
//  SquatsCounterTests
//
//  Created by Dmitro Kryzhanovsky on 08.12.2025.
//

import Testing
import Foundation
@testable import SquatsCounter

struct SquatsCounterTests {

// Fix tests.
    
//    @Test func exerciseRefreshResetsWhenDayChanges() {
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
//        let exercise = Exercise(name: "Test", type: .squating, requiredCount: 10)
//
//        exercise.count = 5
//        exercise.isStart = true
//        exercise.isDone = true
//        exercise.lastRefresh = yesterday
//
//        exercise.refresh()
//
//        #expect(exercise.count == 0)
//        #expect(exercise.isStart == false)
//        #expect(exercise.isDone == false)
//        #expect(exercise.lastRefresh != nil && calendar.isDateInToday(exercise.lastRefresh!))
//    }
//    
//    @Test func dailyRefreshCheck() {
//        let day = makeDate("10.12.2025 11:40")
//        let nextDay = makeDate("11.12.2025 00:00")
//        let previousDay = makeDate("9.12.2025 23:59")
//        
//        #expect(mockNeedsReset(last: day, now: nextDay) == true)
//        #expect(mockNeedsReset(last: day, now: previousDay) == true)
//        #expect(mockNeedsReset(last: nextDay, now: previousDay) == true)
//        #expect(mockNeedsReset(last: nextDay, now: day) == true)
//        #expect(mockNeedsReset(last: previousDay, now: nextDay) == true)
//        #expect(mockNeedsReset(last: previousDay, now: day) == true)
//    }
//    
//    func mockNeedsReset(last: Date, now: Date) -> Bool {
//        var calendar = Calendar.autoupdatingCurrent
//        calendar.timeZone = .autoupdatingCurrent
//
//        let todayStart = calendar.startOfDay(for: now)
//        let lastStart = calendar.startOfDay(for: last)
//
//        return lastStart != todayStart
//    }
    
    // MARK: - Helpers
    
    private func makeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }

    private func makeDate(_ string: String) -> Date {
        let formatter = makeFormatter()
        return formatter.date(from: string)!
    }
}
