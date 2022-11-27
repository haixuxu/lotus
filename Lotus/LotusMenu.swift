//
//  ToolBarItems.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/26.
//

import Foundation
import SwiftUI
import InputMethodKit
import Sparkle
import Preferences

extension  LotusInputController {
    
    @objc func openAbout (_ sender: Any!) {
        NSLog("open about==")
        NSApp.setActivationPolicy(.regular)
        NSApp.orderFrontStandardAboutPanel(sender)
    }

    @objc func checkForUpdates(_ sender: Any!) {
        NSLog("chekc update==")
        NSApp.setActivationPolicy(.regular)
        SUUpdater.shared()?.checkForUpdates(sender)
    }

    override func showPreferences(_ sender: Any!) {
        NSLog("show preference==")
//        preferencesWindowController.show()
        NSApp.setActivationPolicy(.regular)
        LotusPreferencesController.shared.controller.show()
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "关于", action: #selector(openAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "检查更新", action: #selector(checkForUpdates(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "首选项", action: #selector(showPreferences(_:)), keyEquivalent: ""))
        return menu
    }

}
