//
//  LotusService.swift
//  Lotus
//
//  Created by xuxihai on 2024/2/28.
//

import SwiftUI
import InputMethodKit
import Defaults

class LotusService {
    static let instance = LotusService()
    var controller: LotusInputController?
    var client: IMKTextInput?
    var enable: Bool = false
    
    private var  _composedString = ""
    private let candidatesWindow = CandidatesWindow.shared
    private var inputMode: InputMode = .zhhans
    private var hasPrev:Bool = false
    private var hasNext:Bool = false
    private var candidates:[Candidate]?
    var _originalString = "" {
        didSet {
            if self.curPage != 1 {
                // code被重新设置时，还原页码为
                self.curPage = 1
                return
            }
            NSLog("[Service] original changed: \(self._originalString), refresh window")

            // 建议mark originalString, 否则在某些APP中会有问题
            self.markText()

            self._originalString.count > 0 ? self.refreshCandidatesWindow() : candidatesWindow.close()
        }
    }

    private var curPage: Int = 1 {
        didSet(old) {
            guard old == self.curPage else {
                NSLog("[Service] page changed")
                self.refreshCandidatesWindow()
                return
            }
        }
    }
    
    init() {
        // 私有化初始化方法，确保只能通过shared属性获取实例
        controller=nil
        client=nil
    }
    
    private func markText() {
        let attrs = controller!.mark(forStyle: kTSMHiliteConvertedText, at: NSRange(location: NSNotFound, length: 0))
        if let attributes = attrs as? [NSAttributedString.Key: Any] {
            var selected = self._originalString
            if Defaults[.showCodeInWindow] {
                selected = self._originalString.count > 0 ? " " : ""
            }
            let text = NSAttributedString(string: selected, attributes: attributes)
            client?.setMarkedText(text, selectionRange: controller!.selectionRange(), replacementRange: controller!.replacementRange())
        }
    }
    
  
    
    // ---- handlers begin -----

    private func flagChangedHandler(event: NSEvent) -> Bool? {
        // 只有在shift keyup时，才切换中英文输入, 否则会导致shift+[a-z]大写的功能失效
        if Utils.shared.checkShiftKeyUp(event)! {
            NSLog("[Service] toggle mode: \(inputMode)")

            // 把当前未上屏的原始code上屏处理
            _composedString = _originalString
            insertText()

            inputMode = inputMode == .zhhans ? InputMode.enUS : InputMode.zhhans

            let text = inputMode == .zhhans ? "中" : "英"

            // 在输入坐标处，显示中英切换提示
            Utils.shared.tipsWindow.showTips(text, origin: getOriginPoint())
            NSLog("[Service] =====>>true")
            return true
        }
        // 监听.flagsChanged事件只为切换中英文，其它情况不处理
        // 当用户已经按下了非shift的修饰键时，不处理
        if event.type == .flagsChanged || (event.modifierFlags != .init(rawValue: 0) && event.modifierFlags != .shift) {
            NSLog("[Service] =====>>=false")
            return false
        }
        return nil
    }

    private func enModeHandler(event: NSEvent) -> Bool? {
        // 英文输入模式, 不做任何处理
        if inputMode == .enUS {
            return false
        }
        return nil
    }

    private func pageKeyHandler(event: NSEvent) -> Bool? {
        // +/-/arrowdown/arrowup翻页
        let keyCode = event.keyCode
        NSLog("[Service] =======>\(keyCode)")
        if inputMode == .zhhans && _originalString.count > 0 {
            if keyCode == kVK_ANSI_Equal || keyCode == kVK_DownArrow {
                if (hasNext){
                    curPage += 1
                }
                return true
            }
            if keyCode == kVK_ANSI_Minus || keyCode == kVK_UpArrow {
                curPage = curPage > 1 ? curPage - 1 : 1
                return true
            }
        }
        return nil
    }

    private func deleteKeyHandler(event: NSEvent) -> Bool? {
        let keyCode = event.keyCode
        // 删除键删除字符
        if keyCode == kVK_Delete {
            if _originalString.count > 0 {
                _originalString = String(_originalString.dropLast())
                return true
            }
            return false
        }
        return nil
    }

    private func punctutionKeyHandler(event: NSEvent) -> Bool? {
        // 获取输入的字符
        let string = event.characters!

        // 如果输入的字符是标点符号，转换标点符号为中文符号
        if inputMode == .zhhans && punctution.keys.contains(string) {
            _composedString = punctution[string]!
            insertText()
            return true
        }
        return nil
    }

    private func charKeyHandler(event: NSEvent) -> Bool? {
        // 获取输入的字符
        let string = event.characters!

        guard let reg = try? NSRegularExpression(pattern: "^[a-zA-Z]+$") else {
            return nil
        }
        let match = reg.firstMatch(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.count)
        )

        // 当前没有输入非字符并且之前没有输入字符,不做处理
        if  _originalString.count <= 0 && match == nil {
            NSLog("[Service] 非字符,不做处理")
            return nil
        }
        // 当前输入的是英文字符,附加到之前
        if match != nil {
            _originalString += string

            return true
        }
        return nil
    }

    private func numberKeyHandlder(event: NSEvent) -> Bool? {
        // 获取输入的字符
        let string = event.characters!
        // 当前输入的是数字,选择当前候选列表中的第N个字符 v
        if let pos = Int(string), _originalString.count > 0 {
            let index = pos - 1
            guard let candidates = self.candidates else {return nil}
            if index < candidates.count {
                let candiate = candidates[index]
                _composedString = candiate.text
                if _originalString.hasPrefix("zz") && candidates.count<4 {
                    _originalString = candiate.code
                    return true
                }
                if candiate.type == "py" {
                    Utils.shared.sendLog(str: candiate.text)
                }
                insertText()
            } else {
                _originalString += string
            }
            return true
        }
        return nil
    }

    private func enterKeyHandler(event: NSEvent) -> Bool? {
        // 回车键输入原字符
        if event.keyCode == kVK_Return && _originalString.count > 0 {
            // 插入原字符
            _composedString = _originalString
            insertText()
            return true
        }
        return nil
    }

    private func spaceKeyHandler(event: NSEvent) -> Bool? {
        // 空格键输入转换后的中文字符
        if event.keyCode == kVK_Space && _originalString.count > 0 {
            guard let candidates = self.candidates else {return nil}
            if let first = candidates.first {
                _composedString = first.text
                if first.type == "py" {
                    Utils.shared.sendLog(str: first.text)
                }
                insertText()
                candidatesWindow.close()
            }
            return true
        }
        return nil
    }
    
    func handleEvent(event:NSEvent)->Bool{
        let handler = Utils.shared.processHandlers(handlers: [
            pageKeyHandler,
            flagChangedHandler,
            enModeHandler,
           
            deleteKeyHandler,
            charKeyHandler,
            numberKeyHandlder,
            punctutionKeyHandler,
            enterKeyHandler,
            spaceKeyHandler
        ])
        return handler(event) ?? false
    }
    
    func queryCandidates(){
        let result = Lotus.shared.getCandidates(origin: self._originalString, page: curPage)
        self.hasNext = result.hasNext
        self.hasPrev = result.hasPrev
        self.candidates = result.list
    }

    // 更新候选窗口
    func refreshCandidatesWindow() {
        queryCandidates()
        let candidates = self.candidates!
        
        if Defaults[.wubiAutoCommit] && candidates.count == 1 && _originalString.count >= 4 {
            // 满4码唯一候选词自动上屏
            if let candidate = candidates.first {
                _composedString = candidate.text
                insertText()
                return
            }
        }
        if !Defaults[.showCodeInWindow] && candidates.count <= 0 {
            // 不在候选框显示输入码时，如果候选词为空，则不显示候选框
            candidatesWindow.close()
            return
        }
        candidatesWindow.setCandidates(
            hasPrev:self.hasPrev,
            hasNext:self.hasNext,
            candidates: candidates,
            originalString: _originalString,
            topLeft: getOriginPoint()
        )
    }


    // 往输入框插入当前字符
    func insertText() {
        NSLog("[Service] insertText: %@", _composedString)
        _composedString.removingRegexMatches(pattern: "\\([a-z]+\\)")
        let value = NSAttributedString(string: _composedString)
        client?.insertText(value, replacementRange: controller!.replacementRange())
        clean()
    }

    // 获取当前输入的光标位置
    private func getOriginPoint() -> NSPoint {
        var rect = NSRect()
        client?.attributes(forCharacterIndex: 0, lineHeightRectangle: &rect)
        return rect.origin
    }
    
 
    func clean() {
        NSLog("[Service] clean")
        _originalString = ""
        _composedString = ""
        curPage = 1
        candidatesWindow.close()
    }
}
