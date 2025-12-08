//
//  SystemEventMonitor.swift
//  AppLogger
//
//  Created by Aditya Naik on 30/10/25.
//

import UIKit
import Network
import Combine

public final class SystemEventMonitor {
    public static let shared = SystemEventMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SystemEventMonitor.queue")
    private var isMonitoring = false
    
    private init() {}
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        // Battery Monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        // Initial Battery Check
        logBatteryStatus()
        
        // Network Monitoring
        monitor.pathUpdateHandler = { [weak self] path in
            self?.logNetworkChange(path: path)
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        monitor.cancel()
    }
    
    // MARK: - Battery
    
    @objc private func batteryStateDidChange(_ notification: Notification) {
        logBatteryStatus()
    }
    
    @objc private func batteryLevelDidChange(_ notification: Notification) {
        // Only log if low battery to avoid noise? Or every significant change?
        // User asked for "battery low percentage".
        // Let's log if it drops below 20% or 10% step.
        // For now, let's keep it simple: log if low power mode or critical level.
        if UIDevice.current.batteryLevel <= 0.2 && UIDevice.current.batteryState == .unplugged {
             logBatteryStatus(level: .warning)
        }
    }
    
    private func logBatteryStatus(level: LogLevel = .info) {
        let device = UIDevice.current
        let percent = Int(device.batteryLevel * 100)
        let stateString: String
        switch device.batteryState {
        case .unknown: stateString = "Unknown"
        case .unplugged: stateString = "Unplugged"
        case .charging: stateString = "Charging"
        case .full: stateString = "Full"
        @unknown default: stateString = "Unknown"
        }
        
        let msg = "Battery Status: \(percent)% [\(stateString)]"
        
        if level == .warning {
            AppLogger.shared.warning(msg, screen: "SystemEvent")
        } else {
            AppLogger.shared.info(msg, screen: "SystemEvent")
        }
    }
    
    // MARK: - Network
    
    private func logNetworkChange(path: NWPath) {
        let status = path.status
        let isExpensive = path.isExpensive
        let isConstrained = path.isConstrained
        
        var msg = "Network Status Changed: \(status)"
        var level: LogLevel = .info
        
        if status == .unsatisfied {
            level = .warning
            msg += " (No Connection)"
        } else {
            var details: [String] = []
            if path.usesInterfaceType(.wifi) { details.append("WiFi") }
            if path.usesInterfaceType(.cellular) { details.append("Cellular") }
            if path.usesInterfaceType(.wiredEthernet) { details.append("Ethernet") }
            
            msg += " [\(details.joined(separator: ", "))]"
            
            if isExpensive {
                msg += " (Low Data Mode/Expensive)"
            }
            if isConstrained {
                msg += " (Constrained/Slow)"
                level = .warning // Treat constrained as "slowness" proxy
            }
        }

        if level == .warning {
            AppLogger.shared.warning(msg, screen: "SystemEvent")
        } else {
            AppLogger.shared.info(msg, screen: "SystemEvent")
        }
    }
}
