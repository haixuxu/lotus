//
//  AppDelegate.swift
//  Icecat
//
//  Created by xuxihai on 2022/11/19.
//

// AppDelegate.swift
import Cocoa
import InputMethodKit
import Defaults


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let app:Lotus
    func installInputSource() {
          print("install input source")
            registerInputSource()
            deactivateInputSource()
            activateInputSource()
          NSApp.terminate(nil)
   }

    override init() {
        app = Lotus.shared
   }
   func applicationDidFinishLaunching(_ aNotification: Notification) {
       if CommandLine.arguments.count > 1 {
           print("[Lotus] launch argument: \(CommandLine.arguments[1])")
           let command = CommandLine.arguments[1]
           if command == "--install" {
               return installInputSource()
           }
       }
       NSLog("launch application")
   }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
        NSLog("app terminate...")
        let pid: Int32 = ProcessInfo.processInfo.processIdentifier
        print("AppDelegate pid: \(pid)")
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        // Insert code here to tear down your application
        NSLog("app applicationDidBecomeActive...")
        let pid: Int32 = ProcessInfo.processInfo.processIdentifier
        print("AppDelegate pid: \(pid)")
    }
}
