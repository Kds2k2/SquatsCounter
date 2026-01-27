//
//  LogLevel.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//

import OSLog

enum LogLevel {
    case debug
    case info
    case warning
    case error

    var osLogType: OSLogType {
        switch self {
        case .debug:   return .debug
        case .info:    return .info
        case .warning: return .default
        case .error:   return .error
        }
    }

    var prefix: String {
        switch self {
        case .debug:   return "DEBUG"
        case .info:    return "INFO"
        case .warning: return "WARN"
        case .error:   return "ERROR"
        }
    }
}
