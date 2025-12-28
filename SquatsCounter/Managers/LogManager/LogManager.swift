//
//  LogManager.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 26.12.2025.
//

import SwiftUI
import OSLog

final class LogManager {

    static let shared = LogManager()

    private let logger: Logger

    private init() {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "App",
            category: "General"
        )
    }

    func log(
        _ items: Any...,
        level: LogLevel = .debug,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
//#if DEBUG
        let message = items
            .map { String(describing: $0) }
            .joined(separator: " ")

        logger.log(
            level: level.osLogType,
            "<- LOG [\(level.prefix)] \(file):\(line) \(function)\n\(message) ->"
        )
//#endif
    }
}

extension LogManager {

    func debug(_ items: Any..., file: String = #fileID, line: Int = #line, function: String = #function) {
        log(items, level: .debug, file: file, line: line, function: function)
    }

    func info(_ items: Any..., file: String = #fileID, line: Int = #line, function: String = #function) {
        log(items, level: .info, file: file, line: line, function: function)
    }

    func warn(_ items: Any..., file: String = #fileID, line: Int = #line, function: String = #function) {
        log(items, level: .warning, file: file, line: line, function: function)
    }

    func error(_ items: Any..., file: String = #fileID, line: Int = #line, function: String = #function) {
        log(items, level: .error, file: file, line: line, function: function)
    }
}
