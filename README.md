# AppLogger

`AppLogger` is a lightweight and flexible Swift package designed for comprehensive logging in iOS applications. It allows developers to log messages with different severity levels, attach metadata, and integrates with multiple logging providers such as `OSLog` and JSON file storage.

## Features

*   **Customizable Log Levels**: Supports `debug`, `info`, `warning`, `error`, and `none` levels.
*   **Multiple Log Providers**: Easily integrate with `OSLog` for system-level logging or `JSONFileLogStorageProvider` for persistent local storage.
*   **Detailed Log Entries**: Each log entry includes a unique ID, timestamp, message, metadata, file, function, line number, and optional API response details.
*   **API Response Logging**: Special structure to log HTTP status codes, response bodies, request URLs, and headers.

## Installation

### Swift Package Manager (SPM)

To integrate `AppLogger` into your project using Swift Package Manager, follow these steps:

1.  In Xcode, open your project.
2.  Navigate to `File > Add Packages...`.
3.  Enter the URL of your GitHub repository (e.g., `https://github.com/aadit33/AppLogger-Swift.git`) into the search bar.
4.  Choose the version you want to use (e.g., `Up to Next Major Version`).
5.  Click `Add Package`.

## Basic Usage

### 1. Initialize and Configure the Logger

You can configure `AppLogger` with various providers and a desired log level using the `AppLoggerBuilder`.

```swift
import AppLogger

@main
struct MyApp: App {
    init() {
        AppLogger.configure { builder in
            builder.setLogLevel(.debug)
            
            builder.enable(provider: OSLogProvider())
            builder.enable(provider: JSONFileLogStorageProvider())
        }
    }

    var body: some Scene { ... }
}
```

```

### 3. Firebase Crashlytics Integration

To use **Firebase Crashlytics**, ensure you have added the `GoogleService-Info.plist` to your main application bundle (exclude it from the package sources).

#### Setup
1.  **Add the Dependency**: Ensure `AppLogger` is added to your project.
2.  **Add `GoogleService-Info.plist`**: Download this from the Firebase Console and add it to your app target (not the `AppLogger` package).
3.  **Add Run Script**: Add a "Run Script" phase in your app's Build Phases to upload dSYMs:
    ```bash
    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
    ```

#### Configuration

```swift
AppLogger.configure { builder in
    // ... other providers
    
    // Add Crashlytics Provider
    builder.addCrashlytics()
    
    // OR with allowed screens
    // builder.addCrashlytics(allowedScreens: ["Home", "Settings"])
}
```

**Note**: `AppLogger/CrashlyticsProvider` automatically calls `FirebaseApp.configure()` if it hasn't been called yet. Ensure you do not call it multiple times in your application code if using this provider.

### 4. Logging Messages


Once the logger is configured, you can log messages at different levels.

Assuming you have a main `AppLogger` class with static access

```swift
// Log a debug message
AppLogger.shared.debug("User tapped button", metadata: ["buttonId": "loginButton"])

// Log an info message
AppLogger.shared.info("Data loaded successfully")

// Log a warning
AppLogger.shared.warning("API call took too long", metadata: ["duration": "2.5s"])

// Log an error with API response details
let apiResponse = APIResponseLog(statusCode: 401, apiResponse: "Unauthorized", requestURL: "https://api.example.com/user")
AppLogger.shared.error("Authentication failed", apiResponse: apiResponse)
```
