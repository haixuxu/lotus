//
//  TipsWindow.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/27.
//

import Foundation
import Cocoa
import SwiftUI

class TipsWindow {
    private func createTipsWindow() {
        let window = NSWindow()
        window.styleMask = .init(arrayLiteral: .borderless, .fullSizeContentView)
        window.isReleasedWhenClosed = false
        window.level = NSWindow.Level(rawValue: NSWindow.Level.RawValue(CGShieldingWindowLevel() + 2))
        tipsWindow = window
    }

    private func clearTimer() {
        hideTipsWindowTimer?.invalidate()
        if tipsWindow?.isVisible ?? false {
            tipsWindow?.close()
            self.tipsWindow = nil
        }
    }

    private func updateText(text: String) {
        guard let win = tipsWindow else {
            return
        }
        win.contentView = NSHostingView(
            rootView: Text(text)
                .font(.body)
                .padding(6)
        )
    }

    private func showWindow(_ origin: NSPoint) {
        tipsWindow?.setFrameTopLeftPoint(origin)
        tipsWindow?.orderFront(nil)
    }

    func showTips(_ text: String, origin: NSPoint) {
        NSLog("[utils] showTips: \(origin)")
        self.clearTimer()
        self.createTipsWindow()
        self.updateText(text: text)
        self.showWindow(origin)
        self.resetTimer()
    }
    private func resetTimer() {
        hideTipsWindowTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.tipsWindow?.close()
            self.tipsWindow = nil
        }
    }

    private var tipsWindow: NSWindow?
    private var hideTipsWindowTimer: Timer?
}
