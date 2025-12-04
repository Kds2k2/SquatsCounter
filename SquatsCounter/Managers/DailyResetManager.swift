//
//  DailyResetManager.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 04.12.2025.
//

import SwiftUI

final class DailyResetManager {
    static let shared = DailyResetManager()
    private let key = "lastResetDate"
    
    var lastReset: Date? {
        get { UserDefaults.standard.object(forKey: key) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    func needsReset() -> Bool {
        guard let last = lastReset else { return true }
        return !Calendar.current.isDateInToday(last)
    }
}
