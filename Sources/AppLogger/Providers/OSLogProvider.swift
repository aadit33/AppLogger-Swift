//
//  OSLogProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation
import os

public final class OSLogProvider: LogProvider {
    public var isEnabled: Bool = true
    private let logger: Logger

    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "AppLogger", category: String = "AppLogger") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(_ entry: AppLogEntry) {
        let meta = entry.metadata?.map { "\($0.key)=\($0.value)" }.joined(separator: ", ") ?? ""
        let prefix = "[\(entry.level)]"
        let location = "\(entry.file ?? ""):\(entry.line ?? 0) - \(entry.function ?? "")"
        let fullMesaage = "\(prefix) \(entry.message) \(meta.isEmpty ? "" : "| \(meta)") | \(location)"

        switch entry.level {
        case .debug:
            logger.debug("\(fullMesaage)")
        case .info:
            logger.info("\(fullMesaage)")
        case .warning:
            logger.log(level: .default,"\(fullMesaage)")
        case .error:
            logger.error("\(fullMesaage)")
        case .none:
            logger.log("\(fullMesaage)")
        }
    }
}
