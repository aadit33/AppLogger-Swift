//
//  AppLoggerBuilder.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation

public final class AppLoggerBuilder {
    internal var logLevel: LogLevel = .info
    internal var providers: [LogProvider] = []

    public init() {}

    public func setLogLevel(_ level: LogLevel) -> Self {
        self.logLevel = level
        return self
    }

    @discardableResult
    public func enable(provider: LogProvider) -> Self {
        providers.append(provider)
        return self
    }

    @discardableResult
    public func addSentry(dsn: String, environment: String, allowedScreens: [String]? = nil) -> Self {
        let sentryProvider = SentryProvider(dsn: dsn, environment: environment, allowedScreens: allowedScreens)
        providers.append(sentryProvider)
        return self
    }
}