//
//  JSONFileLogStorageProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import Foundation

public final class JSONFileLogStorageProvider: LogProvider {
    public var isEnabled: Bool = true
    private let directoryURL: URL
    private let fileName: String
    private let backupFileName: String
    private let maxLogSize: UInt64
    private let queue = DispatchQueue(label: "JSONFileLogStorageProvider.queue")

    public init(directoryURL: URL? = nil, fileName: String = "applogs.json", maxLogSize: UInt64 = 5_000_000) {
        if let dir = directoryURL {
            self.directoryURL = dir
        } else {
            self.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.fileName = fileName
        self.backupFileName = fileName.replacingOccurrences(of: ".json", with: ".backup.json")
        self.maxLogSize = maxLogSize
    }

    public func log(_ entry: AppLogEntry) {
        queue.async {
            do {
                let fileURL = self.directoryURL.appendingPathComponent(self.fileName)
                var existing: [AppLogEntry] = []
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    existing = (try? decoder.decode([AppLogEntry].self, from: data)) ?? []
                }
                existing.append(entry)
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted
                let out = try encoder.encode(existing)
                try out.write(to: fileURL, options: .atomic)
                
                self.rotateLogsIfNeeded(fileURL: fileURL)
            } catch {
                // best-effort: silently fail or forward to another provider
                print("JSONFileLogStorageProvider error: \(error)")
            }
        }
    }
    
    public func readLogs() async throws -> [AppLogEntry] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let fileURL = self.directoryURL.appendingPathComponent(self.fileName)
                    guard FileManager.default.fileExists(atPath: fileURL.path) else {
                        continuation.resume(returning: [])
                        return
                    }
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let logs = try decoder.decode([AppLogEntry].self, from: data)
                    continuation.resume(returning: logs)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
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
    
    private func rotateLogsIfNeeded(fileURL: URL) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize > maxLogSize {
                let backupURL = self.directoryURL.appendingPathComponent(self.backupFileName)
                
                if FileManager.default.fileExists(atPath: backupURL.path) {
                    try FileManager.default.removeItem(at: backupURL)
                }
                
                try FileManager.default.moveItem(at: fileURL, to: backupURL)
                
                // Create empty log file
                try "[]".write(to: fileURL, atomically: true, encoding: .utf8)
                print("Log file rotated successfully. Backup created at: \(backupURL.path)")
            }
        } catch {
            print("Failed to rotate logs: \(error)")
        }
    }
}
