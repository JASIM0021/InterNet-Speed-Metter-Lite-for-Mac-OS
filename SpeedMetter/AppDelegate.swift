//
//  AppDelegate.swift
//  SpeedMetter
//
//  Created by Sk Jasimuddin on 17/01/1947 Saka.
//

import Foundation
import AppKit
import SwiftUI
import ServiceManagement
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        addAppToLoginItems()
    }
    
    private func addAppToLoginItems() {
        let bundleID = Bundle.main.bundleIdentifier! as CFString
        if !SMLoginItemSetEnabled(bundleID, true) {
            print("Failed to add to login items")
        }
    }
    
    func isInLoginItems() -> Bool {
        guard let jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: Any]] else {
            return false
        }
        let bundleID = Bundle.main.bundleIdentifier!
        return jobs.contains { $0["Label"] as? String == bundleID }
    }
}
