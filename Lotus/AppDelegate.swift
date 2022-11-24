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

extension Defaults.Keys {
    static let wubiCodeTip = Key<Bool>("wubiCodeTip", default: true)
    static let wubiAutoCommit = Key<Bool>("wubiAutoCommit", default: false)
    static let candidateCount = Key<Int>("candidateCount", default: 5)
    static let codeMode = Key<CodeMode>("codeMode", default: CodeMode.wubiPinyin)
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var server = IMKServer()
    var candidatesWindow = IMKCandidates()
    
    let ctx: Context
    override init() {
        ctx = Context.shared
   }
   func applicationDidFinishLaunching(_ aNotification: Notification) {
       if CommandLine.arguments.count > 1 {
           print("[Lotus] launch argument: \(CommandLine.arguments[1])")
           if CommandLine.arguments[1] == "--install" {
               print("install input source")
               registerInputSource()
               deactivateInputSource()
               activateInputSource()
               NSApp.terminate(nil)
               return
           }
       }
       NSLog("launch input source")
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
