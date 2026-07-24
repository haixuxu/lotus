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
                identifier: Preferences.PaneIdentifier(rawValue: "外观"),
                title: "外观",
                toolbarIcon: LotusPreferencesController.icon("paintbrush", fallback: "general")
            ) {
                AppearancePane()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier(rawValue: "短语"),
                title: "短语",
                toolbarIcon: LotusPreferencesController.icon("text.quote", fallback: "advanced")
            ) {
                PhrasesPane()
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
    static let instance = LotusPreferencesController()

    private static func icon(_ symbolName: String, fallback: String) -> NSImage {
        if #available(macOS 11.0, *) {
            return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
                ?? NSImage(named: fallback) ?? NSImage()
        }
        return NSImage(named: fallback) ?? NSImage()
    }
}
