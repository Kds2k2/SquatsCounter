//
//  AppString.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 08.12.2025.
//

import SwiftUI

struct AppString {
    static let title = "DailyQuest"
    
    struct TabBar {
        static let exercise = "Exercises"
        static let jogging = "Jog"
        static let routes = "Routes"
    }
    
    struct Exercise {
        static let title = "Exercises"
    }
    
    struct Jogging {
        static let title = "Jog"
        static let settings = "Settings"
        static let goal = "Goal"
        
        struct State {
            static let title = "End Jog?"
            static let message = "Do you want to save this route or discard it?"
            
            static let start = "Start"
            static let stop = "Stop"
            static let save = "Save"
            static let `continue` = "Continue"
            static let pause = "Pause"
            static let cancel = "Cancel"
            static let discard  = "Discard"
        }
    }
    
    struct Route {
        static let title = "Your Routes"
        
        struct Details {
            static let title = "Route Details"
        }
    }
}
