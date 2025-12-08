//
//  TextFileLogStorageProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import Foundation

public final class TextFileLogStorageProvider: LogProvider {
    public var isEnabled: Bool = true
    private let directoryURL: URL
    private let fileName: String
    private let backupFileName: String
    private let maxLogSize: UInt64
    private let queue = DispatchQueue(label: "TextFileLogStorageProvider.queue")
    private let iso8601Formatter: ISO8601DateFormatter

    public init(directoryURL: URL? = nil, fileName: String = "applogs.txt", maxLogSize: UInt64 = 5_000_000) {
        if let dir = directoryURL {
            self.directoryURL = dir
        } else {
            self.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.fileName = fileName
        // e.g. applogs.txt -> applogs.backup.txt
        let nameWithoutExt = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        self.backupFileName = "\(nameWithoutExt).backup.\(ext)"
        
        self.maxLogSize = maxLogSize
        
        self.iso8601Formatter = ISO8601DateFormatter()
        // Optional: customize format if strict ISO isn't required, but stick to std for now
        // or used a custom DateFormatter for "yyyy-MM-dd HH:mm:ss.SSS" as requested.
        // User requested: datetimestamp [LogType(debug or info, or error)] logs message
    }

    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    public func log(_ entry: AppLogEntry) {
        queue.async {
            self.write(entry: entry)
        }
    }
    
    private func write(entry: AppLogEntry) {
        // Format: datetimestamp [LogType] message
        let timestamp = dateFormatter.string(from: entry.timestamp)
        let level = entry.level.name() // or just description
        let text = "\(timestamp) [\(level)] \(entry.message)\n"
        
        guard let data = text.data(using: .utf8) else { return }
        
        let fileURL = self.directoryURL.appendingPathComponent(self.fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Append
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new
            try? data.write(to: fileURL, options: .atomic)
        }
        
        rotateLogsIfNeeded(fileURL: fileURL)
    }
    
    // Basic rotation logic matching JSON provider
    private func rotateLogsIfNeeded(fileURL: URL) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize > maxLogSize {
                let backupURL = self.directoryURL.appendingPathComponent(self.backupFileName)
                
                if FileManager.default.fileExists(atPath: backupURL.path) {
                    try FileManager.default.removeItem(at: backupURL)
                }
                
                try FileManager.default.moveItem(at: fileURL, to: backupURL)
                
                // Create empty log file? Or just let next write create it.
                // Creating empty might be safer to ensure file exists.
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("TextFileLogStorageProvider: Failed to rotate logs: \(error)")
        }
    }
    
    public func clearLogs() {
        queue.async {
            let fileURL = self.directoryURL.appendingPathComponent(self.fileName)
            let backupURL = self.directoryURL.appendingPathComponent(self.backupFileName)
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: backupURL)
        }
    }
    
    // MARK: - Safe Access for API Upload
    
    /// Returns the URLs of existing log files (current and backup).
    /// Ordered: [Backup, Current] (oldest to newest logic roughly, though backup contains older logs).
    public func getLogFileURLs() -> [URL] {
        var files: [URL] = []
        let backupURL = self.directoryURL.appendingPathComponent(self.backupFileName)
        let fileURL = self.directoryURL.appendingPathComponent(self.fileName)
        
        if FileManager.default.fileExists(atPath: backupURL.path) {
            files.append(backupURL)
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            files.append(fileURL)
        }
        return files
    }
    
    /// Reads all logs (backup + current) and returns as a single string.
    public func fetchAllLogs() throws -> String {
        let urls = getLogFileURLs()
        var content = ""
        for url in urls {
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            content += fileContent
        }
        return content
    }
}
