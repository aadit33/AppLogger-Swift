//
//  FirebaseConfigurator.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import Foundation
import FirebaseCore

internal class FirebaseConfigurator {
    static let shared = FirebaseConfigurator()

    private init() {}

    func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
