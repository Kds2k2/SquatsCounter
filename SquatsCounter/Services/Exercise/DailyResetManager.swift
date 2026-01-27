//
//  DailyResetManager.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 04.12.2025.
//

import Foundation
import SwiftUI

@MainActor
final class DailyResetManager {
    static let shared = DailyResetManager()
    private let key = "lastResetDate"
    
    var lastReset: Date? {
        get { UserDefaults.standard.object(forKey: key) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    func needsReset() -> Bool {
        guard let last = lastReset else { return true }

        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent

        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let lastStart = calendar.startOfDay(for: last)

        return lastStart != todayStart
    }
}
