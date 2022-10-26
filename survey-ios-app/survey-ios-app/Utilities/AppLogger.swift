//
//  AppLogger.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import OSLog

enum LoggerCategory: String {
    case api = "api"
    case lifecycle = "view_lifecycle"
    case storage = "storage"
}

enum LogType {
    case notice
    case debug
    case trace
    case info
    case warning
    case error
    case fault
    case critical
}

enum AppLogger {
    static func log(message: String, category: LoggerCategory, type: LogType) {
        let loggerMesssage = "Category: \(category.rawValue) | Message: \(message)"
        switch type {
        case .notice:
            logger(category).notice("\(message)")
        case .debug:
            logger(category).debug("\(message)")
        case .trace:
            logger(category).trace("\(message)")
        case .info:
            logger(category).info("\(message)")
        case .warning:
            logger(category).warning("\(message)")
        case .error:
            logger(category).error("\(message)")
        case .fault:
            logger(category).fault("\(message)")
        case .critical:
            logger(category).critical("\(message)")
        }
    }

    static func export() throws -> [String] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(timeIntervalSinceLatestBoot: 1)
        return try store
            .getEntries(at: position)
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == "com.survey.test" }
            .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
    }
}

private extension AppLogger {
    static func logger(_ category: LoggerCategory) -> Logger {
        switch category {
        case .api:
            return api
        case .lifecycle:
            return livecycle
        case .storage:
            return storage
        }
    }

    static let api = Logger(subsystem: "com.survey.test", category: LoggerCategory.api.rawValue)
    static let livecycle = Logger(subsystem: "com.survey.test", category: LoggerCategory.lifecycle.rawValue)
    static let storage = Logger(subsystem: "com.survey.test", category: LoggerCategory.storage.rawValue)
}
