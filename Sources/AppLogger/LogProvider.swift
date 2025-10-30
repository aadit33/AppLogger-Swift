//
//  LogProvider.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//


import Foundation

public protocol LogProvider: AnyObject {
    var isEnabled: Bool { get set }
    func log(_ entry: AppLogEntry)
}

public extension LogProvider {
    func enabled(_ enabled: Bool) -> Self {
        self.isEnabled = enabled
        return self
    }
}