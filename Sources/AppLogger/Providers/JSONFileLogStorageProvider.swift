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
    private let queue = DispatchQueue(label: "JSONFileLogStorageProvider.queue")

    public init(directoryURL: URL? = nil, fileName: String = "applogs.json") {
        if let dir = directoryURL {
            self.directoryURL = dir
        } else {
            self.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.fileName = fileName
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
            } catch {
                // best-effort: silently fail or forward to another provider
                print("JSONFileLogStorageProvider error: \(error)")
            }
        }
    }
}
