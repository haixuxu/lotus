//
//  LotusInputController.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/19.
//
import SwiftUI
import InputMethodKit
import Sparkle
import Defaults

class LotusInputController: IMKInputController {

    var uid: String =  UUID().uuidString
 
    override func recognizedEvents(_ sender: Any!) -> Int {
        return Int(NSEvent.EventTypeMask.keyDown.rawValue | NSEvent.EventTypeMask.flagsChanged.rawValue)
    }
    
    // handle event
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        NSLog("[Controller] handle: \(event.debugDescription)")
        return LotusService.instance.handleEvent(event: event)
    }
    
    override func selectionRange() -> NSRange {
        let orgstr = LotusService.instance._originalString
        if Defaults[.showCodeInWindow] {
            return NSRange(location: 0, length: min(1, orgstr.count))
        }
        return NSRange(location: 0, length: orgstr.count)
    }

    @objc func openAbout (_ sender: Any!) {
        NSLog("open about==")
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(sender)
    }

    @objc func checkForUpdates(_ sender: Any!) {
        NSLog("chekc update==")
        NSApp.setActivationPolicy(.accessory)
        SUUpdater.shared()?.checkForUpdates(sender)
    }

    override func showPreferences(_ sender: Any!) {
        NSLog("show preference==")
        NSApp.setActivationPolicy(.accessory)
        LotusPreferencesController.instance.controller.show()
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "关于", action: #selector(openAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "首选项", action: #selector(showPreferences(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "检查更新", action: #selector(checkForUpdates(_:)), keyEquivalent: ""))
        return menu
    }


    override func activateServer(_ sender: Any!) {
        let cid = client()!.bundleIdentifier()!
        LotusService.instance.controller = self
        LotusService.instance.client = client()!
        LotusService.instance.enable=true
        NSLog("[Controller]<\(uid)> active server for client: \(cid)")
    }

    override func deactivateServer(_ sender: Any!) {
        LotusService.instance.enable=false
        NSLog("[Controller]<\(uid)> deactivate server for client: \(client()!.bundleIdentifier()!)")
        LotusService.instance.clean()
    }
}
