//
//  LotusInputController.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/19.
//


//  Created by xuxihai on 2022/11/19.
//
import Cocoa
import InputMethodKit

@objc(LotusInputController)
class LotusInputController: IMKInputController {
    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        NSLog("string:"+string)
        // get client to insert
        guard let client = sender as? IMKTextInput else {
            return false
        }
        client.insertText(string, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        return true
    }
}
