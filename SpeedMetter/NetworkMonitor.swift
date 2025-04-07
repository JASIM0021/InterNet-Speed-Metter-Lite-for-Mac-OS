import SwiftUI
import Network

// Speed unit enum
enum SpeedUnit: String, CaseIterable {
    case bytes = "B/s"
    case kilobytes = "KB/s"
//    case megabits = "Mb/s"
    case megabytes = "MB/s"
    
    func convert(speed: Double) -> Double {
        switch self {
        case .bytes:
            return speed
        case .kilobytes:
            return speed / 1024
//        case .megabits:
//            return (speed / 1024 / 1024) * 8
        case .megabytes:
            return speed / 1024 / 1024
        }
    }
}

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
        let convertedSpeed = selectedUnit.convert(speed: speed)
        return String(format: "%.1f \(selectedUnit.rawValue)", convertedSpeed)
    }
}



struct MenuView: View {
    @ObservedObject var monitor: NetworkMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Unit:", selection: $monitor.selectedUnit) {
                ForEach(SpeedUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.inline)
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}
