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






