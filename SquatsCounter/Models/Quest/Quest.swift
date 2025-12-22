//
//  Quest.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 10.12.2025.
//

import SwiftUI
import SwiftData

@Model
final class Quest {
    var reward: Int
    var repeatable: Bool
    
    init(reward: Int, repeatable: Bool) {
        self.reward = reward
        self.repeatable = repeatable
    }
}
