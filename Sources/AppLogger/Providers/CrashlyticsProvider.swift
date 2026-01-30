//
//  CrashlyticsProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import Foundation
import FirebaseCrashlytics

public class CrashlyticsProvider: LogProvider {
    public var isEnabled: Bool = true
    private let allowedScreens: [String]?

    public init(allowedScreens: [String]? = nil) {
        self.allowedScreens = allowedScreens
        FirebaseConfigurator.shared.configure()
    }

    public func log(_ entry: AppLogEntry) {
        guard isEnabled else { return }
        
        // Filter by screen if allowedScreens is set
        if let allowedScreens = allowedScreens, let screen = entry.screen {
            guard allowedScreens.contains(screen) else { return }
        } else if allowedScreens != nil && entry.screen == nil {
            return
        }

        let crashlytics = Crashlytics.crashlytics()

        // Set Custom Keys
        if let screen = entry.screen {
            crashlytics.setCustomValue(screen, forKey: "screen")
        }
        
        if let file = entry.file { crashlytics.setCustomValue(file, forKey: "file") }
        if let function = entry.function { crashlytics.setCustomValue(function, forKey: "function") }
        if let line = entry.line { crashlytics.setCustomValue(line, forKey: "line") }
        
        if let entryExtras = entry.extras {
            for (key, value) in entryExtras {
                crashlytics.setCustomValue(value, forKey: key)
            }
        }
        
        if let apiResponse = entry.apiResponse {
            crashlytics.setCustomValue(apiResponse.statusCode, forKey: "api_status_code")
            crashlytics.setCustomValue(apiResponse.apiResponse, forKey: "api_response")
            if let url = apiResponse.requestURL { crashlytics.setCustomValue(url, forKey: "request_url") }
        }
        
        // Log Message or Record Error
        let message = entry.message
        crashlytics.log(message)
        
        if entry.level == .error {
             if let error = entry.error {
                 crashlytics.record(error: error)
             } else {
                 // Create a custom error if none provided but level is error
                 let customError = NSError(domain: "AppLogger", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
                 crashlytics.record(error: customError)
             }
        }
    }
}
