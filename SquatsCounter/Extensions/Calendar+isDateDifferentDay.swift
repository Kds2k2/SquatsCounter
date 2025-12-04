//
//  Calendar+isDateDifferentDay.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 04.12.2025.
//

import SwiftUI

extension Calendar {
    func isDateDifferentDay(_ d1: Date?, _ d2: Date?) -> Bool {
        guard let d1 = d1, let d2 = d2 else { return true }
        return !isDate(d1, inSameDayAs: d2)
    }
}
