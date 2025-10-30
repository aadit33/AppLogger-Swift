//
//  ViewController.swift
//  AppLoggerExample
//
//  Created by Aditya Naik on 30/10/25.
//

import UIKit
import AppLogger

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppLogger.configure { builder in
            builder.setLogLevel(.debug)
            
            builder.enable(provider: OSLogProvider())
        }
        
        AppLogger.shared.debug("screen loaded")
        // Do any additional setup after loading the view.
    }
}
