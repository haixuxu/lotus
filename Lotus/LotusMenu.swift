//
//  LotusMenu.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/20.
//
//


import Foundation
import AppKit
import Sparkle
import Defaults
import Preferences

extension LotusInputController {
    /* -- menu actions start -- */
    @objc func openAbout (_ sender: Any!) {
//        NSApp.setActivationPolicy(.accessory)
//        NSApp.activate(ignoringOtherApps: true)
//        NSApp.orderFrontStandardAboutPanel(sender)
        NSLog("about...")
    }
    @objc func checkForUpdates(_ sender: Any!) {
//        NSApp.setActivationPolicy(.accessory)
//        SUUpdater.shared()?.checkForUpdates(sender)
        NSLog("update...")
    }
    override func showPreferences(_ sender: Any!) {
//        NSApp.setActivationPolicy(.accessory)
//        FirePreferencesController.shared.show()
        NSLog("showPreferences...")
    }
    @objc func showUserDictPrefs(_ sender: Any!) {
//        NSApp.setActivationPolicy(.accessory)
//        FirePreferencesController.shared.showPane("用户词库")
        NSLog("showUserDictPrefs...")
    }
    override func menu() -> NSMenu! {
        let menu = NSMenu()
        menu.items = [
            NSMenuItem(title: "首选项", action: #selector(showPreferences(_:)), keyEquivalent: ""),
            NSMenuItem(title: "用户词库", action: #selector(showUserDictPrefs(_:)), keyEquivalent: ""),
            NSMenuItem(title: "检查更新", action: #selector(checkForUpdates(_:)), keyEquivalent: ""),
            NSMenuItem(title: "关于青莲输入法", action: #selector(openAbout(_:)), keyEquivalent: "")
        ]
        return menu
    }
}
