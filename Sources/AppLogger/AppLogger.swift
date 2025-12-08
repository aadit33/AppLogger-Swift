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
        
        if builder.isSystemEventMonitoringEnabled {
            SystemEventMonitor.shared.startMonitoring()
        }
    }
    
    // MARK: - Access
    
    /// Retrieve a registered provider by its type.
    /// Useful for accessing provider-specific features (e.g. retrieving log files).
    public func provider<T: LogProvider>(ofType type: T.Type) -> T? {
        var result: T?
        queue.sync {
            result = providers.first(where: { $0 is T }) as? T
        }
        return result
    }

    // MARK: - Logging API

    public func debug(_ message: String,
                      metadata: [String: String]? = nil,
                      screen: String? = nil,
                      extras: [String: String]? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        log(level: .debug, message: message, metadata: metadata, screen: screen, extras: extras, file: file, function: function, line: line)
    }

    public func info(_ message: String,
                     metadata: [String: String]? = nil,
                     apiResponse: APIResponseLog? = nil,
                     screen: String? = nil,
                     extras: [String: String]? = nil,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(level: .info, message: message, metadata: metadata, apiResponse: apiResponse, screen: screen, extras: extras, file: file, function: function, line: line)
    }

    public func warning(_ message: String,
                        metadata: [String: String]? = nil,
                        screen: String? = nil,
                        extras: [String: String]? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        log(level: .warning, message: message, metadata: metadata, screen: screen, extras: extras, file: file, function: function, line: line)
    }

    public func error(_ message: String,
                      metadata: [String: String]? = nil,
                      screen: String? = nil,
                      extras: [String: String]? = nil,
                      error: Error? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        log(level: .error, message: message, metadata: metadata, screen: screen, extras: extras, error: error, file: file, function: function, line: line)
    }

    // Core
    private func log(level: LogLevel,
                     message: String,
                     metadata: [String: String]? = nil,
                     apiResponse: APIResponseLog? = nil,
                     screen: String? = nil,
                     extras: [String: String]? = nil,
                     error: Error? = nil,
                     file: String,
                     function: String,
                     line: Int) {

        // Filter by current level
        queue.async {
            guard level >= self.level else { return }

            let entry = AppLogEntry(level: level, message: message, metadata: metadata, file: file, function: function, line: line, screen: screen, extras: extras, apiResponse: apiResponse, error: error)

            // Broadcast to providers
            for provider in self.providers where provider.isEnabled {
                provider.log(entry)
            }
        }
    }
}
