//
//  AppLogEntry.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation

public struct AppLogEntry: Codable {
    public let id: UUID
    public let level: LogLevel
    public let message: String
    public let metadata: [String: String]?
    public let timestamp: Date
    public let file: String?
    public let function: String?
    public let line: Int?
    public let screen: String?
    public let extras: [String: String]?
    public let apiResponse: APIResponseLog?
    public let error: Error?
    
    enum CodingKeys: String, CodingKey {
        case id, level, message, metadata, timestamp, file, function, line, screen, extras, apiResponse
    }
    
    public init(
        level: LogLevel,
        message: String,
        metadata: [String: String]? = nil,
        file: String? = nil,
        function: String? = nil,
        line: Int? = nil,
        screen: String? = nil,
        extras: [String: String]? = nil,
        apiResponse: APIResponseLog? = nil,
        error: Error? = nil
    ) {
        self.id = UUID()
        self.level = level
        self.message = message
        self.metadata = metadata
        self.timestamp = Date()
        self.file = file
        self.function = function
        self.line = line
        self.screen = screen
        self.extras = extras
        self.apiResponse = apiResponse
        self.error = error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        level = try container.decode(LogLevel.self, forKey: .level)
        message = try container.decode(String.self, forKey: .message)
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        file = try container.decodeIfPresent(String.self, forKey: .file)
        function = try container.decodeIfPresent(String.self, forKey: .function)
        line = try container.decodeIfPresent(Int.self, forKey: .line)
        screen = try container.decodeIfPresent(String.self, forKey: .screen)
        extras = try container.decodeIfPresent([String: String].self, forKey: .extras)
        apiResponse = try container.decodeIfPresent(APIResponseLog.self, forKey: .apiResponse)
        error = nil // Error is not Codable
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(level, forKey: .level)
        try container.encode(message, forKey: .message)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(file, forKey: .file)
        try container.encodeIfPresent(function, forKey: .function)
        try container.encodeIfPresent(line, forKey: .line)
        try container.encodeIfPresent(screen, forKey: .screen)
        try container.encodeIfPresent(extras, forKey: .extras)
        try container.encodeIfPresent(apiResponse, forKey: .apiResponse)
        // Error is not encoded
    }
}

public struct APIResponseLog: Codable {
    public let statusCode: Int
    public let apiResponse: String
    public let requestURL: String?
    public let responseHeaders: [String: String]?

    public init(
        statusCode: Int,
        apiResponse: String,
        requestURL: String? = nil,
        responseHeaders: [String: String]? = nil
    ) {
        self.statusCode = statusCode
        self.apiResponse = apiResponse
        self.requestURL = requestURL
        self.responseHeaders = responseHeaders
    }
}
