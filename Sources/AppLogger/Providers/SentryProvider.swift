//
//  SentryProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import Foundation
import Sentry

public class SentryProvider: LogProvider {
    public var isEnabled: Bool = true
    private let allowedScreens: [String]?

    public init(dsn: String, environment: String, allowedScreens: [String]? = nil) {
        self.allowedScreens = allowedScreens
        
        SentrySDK.start { options in
            options.dsn = dsn
            options.enableAutoBreadcrumbTracking = true
            options.attachScreenshot = true
            options.attachViewHierarchy = true
            options.appHangTimeoutInterval = 60
            options.environment = environment
            
#if DEBUG
            options.debug = true
            options.enableNetworkBreadcrumbs = false
            options.enableUIViewControllerTracing = false
            options.enableAutoBreadcrumbTracking = false
#else
            options.debug = false
#endif
            
            options.beforeSend = { event in
#if DEBUG
                return event
#else
                // Assuming we don't have Common.isNetworkConnected() here, we rely on Sentry's internal handling or add a check if needed.
                // For now, we return the event as is.
                return event
#endif
            }
        }
    }

    public func log(_ entry: AppLogEntry) {
        guard isEnabled else { return }
        
        // Filter by screen if allowedScreens is set
        if let allowedScreens = allowedScreens, let screen = entry.screen {
            guard allowedScreens.contains(screen) else { return }
        } else if allowedScreens != nil && entry.screen == nil {
            // If allowedScreens is set but entry has no screen, we might want to skip it or log it.
            // Based on "enable sentry event for certailn screen s", we assume we only log if it matches.
            return
        }

        let sentryLevel: SentryLevel
        switch entry.level {
        case .debug: sentryLevel = .debug
        case .info: sentryLevel = .info
        case .warning: sentryLevel = .warning
        case .error: sentryLevel = .error
        case .none: sentryLevel = .info
        }

        let event = Event(level: sentryLevel)
        event.message = SentryMessage(formatted: entry.message)
        
        if let error = entry.error {
            event.error = error
        }
        
        var tags = entry.metadata ?? [:]
        if let screen = entry.screen {
            tags["screen"] = screen
        }
        event.tags = tags
        
        var extra: [String: Any] = [:]
        if let entryExtras = entry.extras {
            for (key, value) in entryExtras {
                extra[key] = value
            }
        }
        
        if let file = entry.file { extra["file"] = file }
        if let function = entry.function { extra["function"] = function }
        if let line = entry.line { extra["line"] = line }
        if let apiResponse = entry.apiResponse {
            extra["api_status_code"] = apiResponse.statusCode
            extra["api_response"] = apiResponse.apiResponse
            if let url = apiResponse.requestURL { extra["request_url"] = url }
        }
        event.extra = extra

        SentrySDK.capture(event: event)
    }
}
