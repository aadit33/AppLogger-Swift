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
            
            // Add Sentry provider
             builder.addSentry(
                 dsn: "https://6fd40efa504cf02741f53f4a2b5e4911@o4510418135416832.ingest.us.sentry.io/4510418138824704",
                 environment: "production",
                 allowedScreens: ["Home", "Profile"] // Only logs from these screens will be sent to Sentry
             )
        }
        
        AppLogger.shared.debug("screen loaded")
        
        AppLogger.shared.info(
            "User tapped button",
            metadata: ["userif": "123"],
            screen: "Home",
            extras: ["button_id": "login_btn", "click_count": "1"]
        )
        // Do any additional setup after loading the view.
    }
    
   
}
