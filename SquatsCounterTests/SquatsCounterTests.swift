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

    @Test func exerciseRefreshResetsWhenDayChanges() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let exercise = Exercise(name: "Test", type: .squating, requiredCount: 10)

        exercise.count = 5
        exercise.isStart = true
        exercise.isDone = true
        exercise.lastRefresh = yesterday

        exercise.refresh()

        #expect(exercise.count == 0)
        #expect(exercise.isStart == false)
        #expect(exercise.isDone == false)
        #expect(exercise.lastRefresh != nil && calendar.isDateInToday(exercise.lastRefresh!))
    }

    @Test func exerciseRefreshKeepsStateSameDay() {
        let exercise = Exercise(name: "Test", type: .squating, requiredCount: 10)

        exercise.count = 7
        exercise.isStart = true
        exercise.isDone = false
        exercise.lastRefresh = Date()

        exercise.refresh()

        #expect(exercise.count == 7)
        #expect(exercise.isStart == true)
        #expect(exercise.isDone == false)
    }

    @Test func exerciseInitSetsDefaults() {
        let calendar = Calendar.current
        let exercise = Exercise(name: "Test", type: .squating, requiredCount: 10)

        #expect(exercise.count == 0)
        #expect(exercise.isStart == false)
        #expect(exercise.isDone == false)
        #expect(exercise.lastRefresh != nil && calendar.isDateInToday(exercise.lastRefresh!))
        #expect(exercise.streak != nil)
    }

    @Test func streakRecordsSingleCompletion() {
        let streak = Streak()

        streak.recordCompletion()

        #expect(streak.current == 1)
        #expect(streak.best == 1)
        #expect(streak.lastCompleted != nil)
    }

    @Test func streakAdvancesOnConsecutiveDay() {
        let calendar = Calendar.current
        let streak = Streak()

        streak.current = 1
        streak.best = 1
        streak.lastCompleted = calendar.date(byAdding: .day, value: -1, to: Date())

        streak.recordCompletion()

        #expect(streak.current == 2)
        #expect(streak.best == 2)
        #expect(streak.lastCompleted != nil && calendar.isDateInToday(streak.lastCompleted!))
    }

    @Test func streakIgnoresDuplicateSameDayCompletion() {
        let calendar = Calendar.current
        let streak = Streak()

        streak.recordCompletion()
        let firstCompletion = streak.lastCompleted

        streak.recordCompletion()

        #expect(streak.current == 1)
        #expect(streak.best == 1)
        #expect(firstCompletion != nil && calendar.isDate(streak.lastCompleted!, inSameDayAs: firstCompletion!))
    }

    @Test func streakResetsAfterMissedDayWhenRecording() {
        let calendar = Calendar.current
        let streak = Streak()

        streak.current = 3
        streak.best = 5
        streak.lastCompleted = calendar.date(byAdding: .day, value: -3, to: Date())

        streak.recordCompletion()

        #expect(streak.current == 1)
        #expect(streak.best == 5)
        #expect(streak.lastCompleted != nil && calendar.isDateInToday(streak.lastCompleted!))
    }

    @Test func streakCheckResetsAfterGap() {
        let calendar = Calendar.current
        let streak = Streak()

        streak.current = 3
        streak.best = 5
        streak.lastCompleted = calendar.date(byAdding: .day, value: -2, to: Date())

        streak.check()

        #expect(streak.current == 0)
        #expect(streak.best == 5)
    }

    @Test func streakCheckKeepsConsecutiveDay() {
        let calendar = Calendar.current
        let streak = Streak()

        streak.current = 2
        streak.best = 4
        streak.lastCompleted = calendar.date(byAdding: .day, value: -1, to: Date())

        streak.check()

        #expect(streak.current == 2)
        #expect(streak.best == 4)
    }

}
