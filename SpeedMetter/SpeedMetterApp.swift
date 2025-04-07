//
//  ContentView.swift
//  SpeedMetter
//
//  Created by Sk Jasimuddin on 17/01/1947 Saka.
//

import SwiftUI


@main
struct NetworkSpeedApp: App {
    @StateObject private var monitor = NetworkMonitor()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView() // We don't need a settings window
        }
        
        MenuBarExtra {
            MenuView(monitor: monitor)
        } label: {
            Text("↓\(monitor.formattedSpeed(monitor.downloadSpeed)) ↑\(monitor.formattedSpeed(monitor.uploadSpeed))")
                .font(.system(size: 12, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}

struct ContentView: View {
    @ObservedObject var monitor: NetworkMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Download: \(monitor.downloadSpeed)")
            Text("Upload: \(monitor.uploadSpeed)")
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}
