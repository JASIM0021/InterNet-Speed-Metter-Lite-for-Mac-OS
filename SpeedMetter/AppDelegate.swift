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
    
    func addAppToLoginItems() {
        DispatchQueue.main.async {
            let appPath = Bundle.main.bundlePath
            let script = """
            tell application "System Events"
                if not (exists login item "\(appPath)") then
                    make login item at end with properties {path:"\(appPath)", hidden:false}
                end if
            end tell
            """

            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
            }

            if let error = error {
                print("❌ Failed to add login item: \(error)")

                // Show alert only if it's a known Automation denial error (e.g., -600 or -1743)
                if let errorNumber = error["NSAppleScriptErrorNumber"] as? Int, [ -600, -1743 ].contains(errorNumber) {
                    let alert = NSAlert()
                    alert.messageText = "Enable Automation Access"
                    alert.informativeText = """
                    To launch this app at login, please allow it to control 'System Events' under:

                    System Settings → Privacy & Security → Automation
                    """
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Open Settings")
                    alert.addButton(withTitle: "Cancel")

                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            } else {
                print("✅ Login item added successfully.")
            }
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
