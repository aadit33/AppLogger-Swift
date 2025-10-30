//
//  LogLevel.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation

public enum LogLevel: Int, Comparable, Codable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case none = 99

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}