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
    let type: String  // wb | pyg
}

enum CodeMode: Int, CaseIterable, Decodable, Encodable {
    case wubi
    case pinyin
    case wubiPinyin
}

struct NetCandidate: Codable {
    let wbcode: String
    let text: String
    let weight: Int
}

struct CandidatesResponse: Codable {
    let errcode: Int
    let errmsg: String
    let list: [NetCandidate]
}

extension UserDefaults {
    @objc dynamic var codeMode: Int {
        get {
            return integer(forKey: "codeMode")
        }
        set {
            set(newValue, forKey: "codeMode")
        }
    }
}

func dictAppendTrie(dictfile: String, trie: Trie<String>,prefix:String){
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

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

class Context: NSObject {
    private var database: OpaquePointer?
    private var queryStatement: OpaquePointer?
    private var preferencesObserver: Defaults.Observation!
    private var dataTree:Trie<String>?

    override init() {
        super.init()

        self.buildDictTrie()

        preferencesObserver = Defaults.observe(keys: .codeMode, .candidateCount) { () in
            self.buildDictTrie()
        }
    }

    deinit {
        preferencesObserver.invalidate()
    }

    private func buildDictTrie() {
        self.dataTree = Trie<String>.init()
        dictAppendTrie(dictfile: "wb_table", trie: dataTree!,prefix:"1")
        dictAppendTrie(dictfile: "py_table", trie: dataTree!,prefix:"2")
    }

    var server: IMKServer = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
    func getCandidates(origin: String = String(), page: Int = 1) -> [Candidate] {
        if origin.count <= 0 {
            return []
        }
        NSLog("get local candidate, origin: \(origin)")
//        var db: OpaquePointer?
        let limit = 6
        let offset = (page - 1) * limit
        guard let queryRets = self.dataTree?.find(keyword: origin, offset: Int8(offset), limit: Int8(limit)) else {
            return []
        }
 
        var candidates: [Candidate] = []
        for item in queryRets {
            let first = item.value.dropFirst();
            var type:String
            if first == "2" {
                type = "py"
            }else {
                type = "wb"
            }
            
            var text = item.value.substring(from: 1)
            if item.code.count != 0 {
                text = "\(text)~\(item.code)"
            }
            let candidate = Candidate(code: item.code, text: text, type: type)
            candidates.append(candidate)
        }
        return candidates
    }
    
    static let shared = Context()
}
