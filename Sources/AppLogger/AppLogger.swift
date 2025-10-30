//
//  AppLogger.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation

public final class AppLogger {
    public static let shared = AppLogger()

    private var providers: [LogProvider] = []
    private var level: LogLevel = .info
    private let queue = DispatchQueue(label: "AppLogger.queue", qos: .utility)

    private init() {}

    /// Configure at start
    public static func configure(_ configureBlock: (AppLoggerBuilder) -> Void) {
        let builder = AppLoggerBuilder()
        configureBlock(builder)

        let instance = AppLogger.shared
        instance.queue.sync {
            instance.level = builder.logLevel
            instance.providers = builder.providers
        }
    }

    // MARK: - Logging API

    public func debug(_ message: String,
                      metadata: [String: String]? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        log(level: .debug, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public func info(_ message: String,
                     metadata: [String: String]? = nil,
                     apiResponse: APIResponseLog? = nil,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(level: .info, message: message, metadata: metadata, apiResponse: apiResponse, file: file, function: function, line: line)
    }

    public func warning(_ message: String,
                        metadata: [String: String]? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        log(level: .warning, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public func error(_ message: String,
                      metadata: [String: String]? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        log(level: .error, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    // Core
    private func log(level: LogLevel,
                     message: String,
                     metadata: [String: String]? = nil,
                     apiResponse: APIResponseLog? = nil,
                     file: String,
                     function: String,
                     line: Int) {

        // Filter by current level
        queue.async {
            guard level >= self.level else { return }

            let entry = AppLogEntry(level: level, message: message, metadata: metadata, file: file, function: function, line: line, apiResponse: apiResponse)

            // Broadcast to providers
            for provider in self.providers where provider.isEnabled {
                provider.log(entry)
            }
        }
    }
}
