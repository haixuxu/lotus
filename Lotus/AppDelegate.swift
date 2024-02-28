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


let kConnectionName = "Lotus_90_Connection"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var server: IMKServer
    
    override init() {
       server = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
   }
   func applicationDidFinishLaunching(_ aNotification: Notification) {
       let argstr = CommandLine.arguments.joined(separator: " ")
       NSLog("argstr====\(argstr)")
       if CommandLine.arguments.count > 1 {
           print("[Lotus] launch argument: \(CommandLine.arguments[1])")
           let command = CommandLine.arguments[1]
           if command == "--develop" {
               activateInputSource()
               return
           }
           if command == "--install" {
               NSLog("install input source")
                 registerInputSource()
                 deactivateInputSource()
                 activateInputSource()
               NSApp.terminate(nil)
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
