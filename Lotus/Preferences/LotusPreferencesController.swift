////
////  LotusPreferencesController.swift
////  Lotus
////
////  Created by xuxihai on 2022/11/26.
////
//
//import Foundation
//import Preferences
//
//class FirePreferencesController: NSObject, NSWindowDelegate {
//    private var controller: PreferencesWindowController?
//    static let shared = FirePreferencesController()
//
//    var isVisible: Bool {
//        controller?.window?.isVisible ?? false
//    }
//
//    private func initController() {
//        if let controller = controller {
//            controller.show()
//            return
//        }
//        self.controller = PreferencesWindowController(
//            panes: [
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "基本"),
//                     title: "基本",
//                    toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
//                ) {
//                    GeneralPane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "标点符号"),
//                     title: "标点符号",
//                    toolbarIcon: NSImage(named: NSImage.fontPanelName) ?? NSImage(named: "general")!
//                ) {
//                    PunctuationPane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "用户词库"),
//                     title: "用户词库",
//                    toolbarIcon: NSImage(named: NSImage.multipleDocumentsName) ?? NSImage(named: "general")!
//                ) {
//                    UserDictPane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "应用"),
//                     title: "应用",
//                    toolbarIcon: NSImage(named: NSImage.computerName) ?? NSImage(named: "general")!
//                ) {
//                    ApplicationPane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "主题"),
//                     title: "主题",
//                    toolbarIcon: NSImage(named: NSImage.colorPanelName) ?? NSImage(named: "general")!
//                ) {
//                    ThemePane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "统计"),
//                     title: "统计",
//                    toolbarIcon: NSImage(named: NSImage.bonjourName) ?? NSImage(named: "general")!
//                ) {
//                    StatisticsPane()
//                },
//                Preferences.Pane(
//                    identifier: Preferences.PaneIdentifier(rawValue: "高级"),
//                     title: "高级",
//                    toolbarIcon: NSImage(named: NSImage.advancedName)!
//                ) {
//                    ThesaurusPane()
//                }
//            ],
//            style: .toolbarItems
//        )
//        self.controller?.window?.delegate = self
//    }
//
//    func showPane(_ name: String) {
//        initController()
//        controller?.show(preferencePane: Preferences.PaneIdentifier(rawValue: name))
//    }
//
//    func show() {
//        initController()
//        controller?.show()
//    }
//}
