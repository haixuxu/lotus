//
//  AppDelegate.swift
//  Icecat
//
//  Created by xuxihai on 2022/11/19.
//

// AppDelegate.swift
import Cocoa
import InputMethodKit

// necessary to launch this app
class NSManualApplication: NSApplication {
    private let appDelegate = AppDelegate()

    override init() {
        super.init()
        NSLog("init===")
        self.delegate = appDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var server = IMKServer()
    var candidatesWindow = IMKCandidates()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let connectName = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String
        // Insert code here to initialize your application
        server = IMKServer(name: connectName, bundleIdentifier: Bundle.main.bundleIdentifier)
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel, styleType: kIMKMain)
        NSLog("tried connection")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
        NSLog("app terminate...")
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        // Insert code here to tear down your application
        NSLog("app applicationDidBecomeActive...")
    }
}
