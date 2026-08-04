//
//  LogType.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation
import OSLog

/// almost same as `OSLogType` but with an emoji
enum LogType { /// we made this do decouple the `OSLog` library from being imported everytime we need to use `OSLogType` in
    case info
    case analytic
    case warning
    case severe

    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .analytic: return "📊"
        case .warning: return "⚠️"
        case .severe: return "🚨"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .info: return .info
        case .analytic: return .default
        case .warning: return .error
        case .severe: return .fault
        }
    }
}

actor LogSystem {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AIChat", category: "ConsoleLogger")

    nonisolated func log(_ level: LogType, _ message: String) {
        Task {
            await log(level: level.osLogType, message: "\(level.emoji) \(message)")
        }
    }

    private func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
}
