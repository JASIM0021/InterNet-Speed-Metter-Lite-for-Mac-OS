//
//  NetworkMonitor.swift
//  SpeedMetter
//
//  Created by Sk Jasimuddin on 18/01/1947 Saka.
//

import Foundation
import Network
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var downloadSpeed: Double = 0
    @Published var uploadSpeed: Double = 0
    @Published var selectedUnit: SpeedUnit = .kilobytes {
        didSet {
            UserDefaults.standard.set(selectedUnit.rawValue, forKey: "speedUnit")
        }
    }
    
    private var lastBytesReceived: Int64 = 0
    private var lastBytesSent: Int64 = 0
    private var lastUpdateTime: Date = Date()
    
    init() {
        // Load saved unit preference
        if let savedUnit = UserDefaults.standard.string(forKey: "speedUnit"),
           let unit = SpeedUnit(rawValue: savedUnit) {
            selectedUnit = unit
        }
        
        monitor.pathUpdateHandler = { path in
            // Handle connection changes if needed
        }
        monitor.start(queue: queue)
        startSpeedMonitoring()
    }
    
    func startSpeedMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateNetworkSpeed()
        }
    }
    
    func updateNetworkSpeed() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return }
        
        var totalBytesReceived: Int64 = 0
        var totalBytesSent: Int64 = 0
        
        var pointer = ifaddr
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }
            
            guard let interface = pointer?.pointee else { continue }
            let name = String(cString: interface.ifa_name)
            guard name == "en0" || name == "pdp_ip0" else { continue }
            
            if let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalBytesReceived += Int64(data.pointee.ifi_ibytes)
                totalBytesSent += Int64(data.pointee.ifi_obytes)
            }
        }
        
        freeifaddrs(ifaddr)
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(self.lastUpdateTime)
        
        if timeInterval > 0 {
            let received = totalBytesReceived - self.lastBytesReceived
            let sent = totalBytesSent - self.lastBytesSent
            
            self.downloadSpeed = Double(received) / timeInterval
            self.uploadSpeed = Double(sent) / timeInterval
        }
        
        self.lastBytesReceived = totalBytesReceived
        self.lastBytesSent = totalBytesSent
        self.lastUpdateTime = now
    }
    
    func formattedSpeed(_ speed: Double) -> String {
        let unit: String
        let convertedSpeed: Double

        switch speed {
        case 0..<1024:
            unit = "B/s"
            convertedSpeed = speed
        case 1024..<(1024 * 1024):
            unit = "KB/s"
            convertedSpeed = speed / 1024
        case (1024 * 1024)..<(1024 * 1024 * 1024):
            unit = "MB/s"
            convertedSpeed = speed / (1024 * 1024)
        default:
            unit = "GB/s"
            convertedSpeed = speed / (1024 * 1024 * 1024)
        }

        return String(format: "%.1f %@", convertedSpeed, unit)
    }

}
