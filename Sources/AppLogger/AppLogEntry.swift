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
    public let apiResponse: APIResponseLog?
    
    public init(
        level: LogLevel,
        message: String,
        metadata: [String: String]? = nil,
        file: String? = nil,
        function: String? = nil,
        line: Int? = nil,
        apiResponse: APIResponseLog? = nil
    ) {
        self.id = UUID()
        self.level = level
        self.message = message
        self.metadata = metadata
        self.timestamp = Date()
        self.file = file
        self.function = function
        self.line = line
        self.apiResponse = apiResponse
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
