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
        let today = Date()
        let calendar = Calendar.current
        
        if let last = lastCompleted, calendar.isDate(last, inSameDayAs: today) {
            return
        }
        
        if let last = lastCompleted, calendar.isDate(today, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: last)!) {
            current += 1
        } else {
            current = 1
        }
        
        if current > best { best = current }

        lastCompleted = today
    }
    
    func check() {
        let today = Date()
        let calendar = Calendar.current
        
        if let last = lastCompleted, !calendar.isDate(today, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: last)!) {
            current = 0
        }
    }
}
