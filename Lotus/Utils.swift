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
    
    func parseDictKeyValue(dictfile: String, callback: (String,Array<Substring>)->Void){
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
                callback(String(val),parts)
            }
        }
    }
    
    func sendLog(str:String){
        NSLog("sendLog str:\(str)")
        let apiurl = "https://www.75cos.com/input/set?word=\(str.URLEncodedString()!)"
        let url = URL(string: apiurl)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard error == nil else {
               NSLog("[Service] 网络出错:\(error!.localizedDescription)")
               return
             }
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    static let shared = Utils()
}
