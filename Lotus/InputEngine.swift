//
//  Lotus.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/21.
//

import Foundation
import Cocoa
import InputMethodKit
import SQLite3
import Sparkle
import Defaults

let kConnectionName = "Lotus_90_Connection"

struct Candidate: Hashable {
    let code: String
    let text: String
    let type: String  // custom | wb | py | sp
}

enum CodingStrategy: Int, CaseIterable, Decodable, Encodable {
    case wubi
    case pinyin
    case wubiPinyin
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

class InputEngine: NSObject {
    private var dataTree:Trie?
    private var suggestCount:Int = 6
    private var strategy:CodingStrategy = CodingStrategy.wubiPinyin

    override init() {
        super.init()
        self.suggestCount = Defaults[.candidateCount]
        self.strategy = Defaults[.codeStrategy]
        NSLog("Engine:\(self.strategy),\(self.suggestCount)")
        self.buildDictTrie()
        
        Defaults.observe(keys: .candidateCount, .codeStrategy) { () in
            self.suggestCount = Defaults[.candidateCount]
            self.strategy = Defaults[.codeStrategy]
        }.tieToLifetime(of: self)
    }

    deinit {
        dataTree = nil
    }

    private func buildDictTrie() {
        self.dataTree = Trie.init()
        let starttime =  Date().currentTimeMillis()
        dictAppendTrie(dictfile: "wb_table", trie: dataTree!,prefix:"1")
        dictAppendTrie(dictfile: "py_table", trie: dataTree!,prefix:"2")
        dictAppendTrie(dictfile: "sp_table", trie: dataTree!,prefix:"3")
        
        let endtime =  Date().currentTimeMillis()

        print("build dict index time:\(endtime-starttime)ms")
    }

    var server: IMKServer = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
    func getCandidates(origin: String = String(), page: Int = 1) -> [Candidate] {
        if origin.count <= 0 {
            return []
        }
        NSLog("get local candidate, origin: \(origin)")

        let limit = self.suggestCount
        var start = 0;
        let offset = (page - 1) * limit
        var candidates: [Candidate] = []
        let starttime =  Date().currentTimeMillis()
        self.dataTree?.find(keyword: origin, callback:  { (code,value) in
            if value.count < 2 {
                return false
            }
            let first = value.substring(to: 1)
            let value2 = value.dropFirst(); // delete one return
            NSLog("first==\(value)===\(first),\(self.strategy), \(CodingStrategy.wubi)")
            if self.strategy == CodingStrategy.wubi && first == "2" {
                return false;
            }
            if self.strategy == CodingStrategy.pinyin && first == "1" {
                return false;
            }
            if start >= offset {
                let suggest = self.buildSuggest(code: code, value: String(value2),type:first)
                candidates.append(suggest)
            }
            start = start + 1
            if start >= offset + limit {
                return true
            }else {
                return false
            }
        })
        let endtime =  Date().currentTimeMillis()
        print("keyword find time:\(endtime-starttime)ms")
        return candidates
    }
    
    func buildSuggest(code:String,value:String, type:String)->Candidate {
        var text = value
        if code.count != 0 {
            text = "\(text)~\(code)"
        }
        return Candidate(code: code, text: text, type: type)
    }
    
    static let server = InputEngine()
}
