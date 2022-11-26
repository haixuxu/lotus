//
//  LotusPreferencesController.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/26.
//

import Foundation

import Foundation
import Preferences

class LotusPreferencesController {
    lazy var controller = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier(rawValue: "基本"),
                 title: "基本",
                toolbarIcon: NSImage(named: "general")!
            ) {
                GeneralPane()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier(rawValue: "高级"),
                 title: "高级",
                toolbarIcon: NSImage(named: "advanced")!
            ) {
                WordStockPane()
            }
        ]
    )
    static let shared = LotusPreferencesController()
}
