//
//  Utils.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/21.
//

import Foundation
import Cocoa
import InputMethodKit

class Utils {

    let tipsWindow = TipsWindow()
    var checkShiftKeyUp: (NSEvent) -> Bool?
    private var hideTipsWindowTimer: Timer?

    init() {
        // 检查shift键被抬起
        func createCheckShiftKeyUpFn() -> (NSEvent) -> Bool {
            var lastModifier: NSEvent.ModifierFlags = .init(rawValue: 0)
            func checkShiftKeyUp(_ event: NSEvent) -> Bool {
                if event.type == .flagsChanged
                    && event.modifierFlags == .init(rawValue: 0)
                    && lastModifier == .shift {  // shift键抬起
                    lastModifier = event.modifierFlags
                    return true
                }
                lastModifier = event.type == .flagsChanged ? event.modifierFlags : .init(rawValue: 0)
                return false
            }
            return  checkShiftKeyUp
        }
        self.checkShiftKeyUp = createCheckShiftKeyUpFn()
    }

    func processHandlers<T>(
            handlers: [(NSEvent) -> T?]
        ) -> ((NSEvent) -> T?) {
            func handleFn(event: NSEvent) -> T? {
                var count = 0
                for handler in handlers {
                    count = count + 1
                    if let result = handler(event) {
                        NSLog("result====\(result)")
                        return result
                    }
                }
                NSLog("=====result=>\(count)")
                return nil
            }
            return handleFn
        }
    
    func getScreenFromPoint(_ point: NSPoint) -> NSScreen? {
           // find current screen
           for screen in NSScreen.screens {
               if screen.frame.contains(point) {
                   return screen
               }
           }
           return NSScreen.main
       }
    
    func dictAppendTrie(dictfile: String, trie: Trie,prefix:String){
        guard let fileURL = Bundle.main.path(forResource: dictfile ,ofType:"txt") else {
            fatalError("File not found:\(dictfile)")
        }

        guard let reader = LineReader(path: fileURL) else {
            print("cannot open file \(dictfile)")
            return; // cannot open file
        }

        for line in reader {
            let line2 = line.trimmingCharacters(in: .whitespacesAndNewlines)
            var parts = line2.split(separator: " ")
            if parts.count >= 2 {
                let val = parts[0]
                parts.removeFirst()
                trie.insert(word: String(val), value: parts.map({s in String.init(prefix+s)}))
            }
        }
    }
    static let shared = Utils()
}
