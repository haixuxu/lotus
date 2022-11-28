//
//  Lotus.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/21.
//

import Foundation
import Cocoa
import InputMethodKit
//import SQLite3
import Sparkle
import Defaults

let kConnectionName = "Lotus_90_Connection"
let prefixType:[String:String] = ["0":"user", "1":"wb", "2":"py","3":"sp"]

class Lotus: NSObject {

    static let nextPageBtnTapped = Notification.Name("Lotus.nextPageBtnTapped")
    static let prevPageBtnTapped = Notification.Name("Lotus.prevPageBtnTapped")
    
    private var dataTree:Trie?
    private var suggestCount:Int = 6
    private var strategy:CodingStrategy = CodingStrategy.wubiPinyin

    override init() {
        super.init()
        self.suggestCount = Defaults[.candidateCount]
        self.strategy = Defaults[.codeStrategy]
        NSLog("Config==:\(self.strategy),\(self.suggestCount)")
        self.buildDictTrie()
        
        Defaults.observe(keys: .candidateCount, .codeStrategy) { () in
            self.suggestCount = Defaults[.candidateCount]
            self.strategy = Defaults[.codeStrategy]
        }.tieToLifetime(of: self)
    }

    deinit {
        dataTree = nil
    }
    public func buildDictTrie() {
        self.dataTree = Trie.init()
        let starttime =  Date().currentTimeMillis()
        Utils.shared.dictAppendTrie(dictfile: "userdict", trie: dataTree!,prefix:"0")
        Utils.shared.dictAppendTrie(dictfile: "wb_table", trie: dataTree!,prefix:"1")
        Utils.shared.dictAppendTrie(dictfile: "py_table", trie: dataTree!,prefix:"2")
        Utils.shared.dictAppendTrie(dictfile: "sp_table", trie: dataTree!,prefix:"3")
        
        let endtime =  Date().currentTimeMillis()

        print("build dict index time:\(endtime-starttime)ms")
    }

    var server: IMKServer = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier)
    func getCandidates(origin: String = String(), page: Int = 1) -> CandidatesData {
//        var candidates: [Candidate] = []
        var queryRes:CandidatesData = CandidatesData(hasPrev:false, hasNext:false,list:[])
        if page != 1 {
            queryRes.hasPrev=true
        }
        if origin.count <= 0 {
            return queryRes
        }
        NSLog("get local candidate, origin: \(origin)")

        let limit = self.suggestCount
        var start = 0;
        let offset = (page - 1) * limit
        let last = offset + limit
        let starttime =  Date().currentTimeMillis()
        NSLog("sstart:\(start),===\(last)")
        self.dataTree?.find(keyword: origin, callback:  { (code,value) in
            if value.count < 2 {
                return false
            }
            let first = value.substring(to: 1)
         
//            NSLog("first==\(value)===\(first),\(self.strategy), \(CodingStrategy.wubi)")
            if self.strategy == CodingStrategy.wubi && first == "2" {
                return false;
            }
            if self.strategy == CodingStrategy.pinyin && first == "1" {
                return false;
            }
            if start >= offset && start < last {
                guard let type = prefixType[first] else {return false}
                let suggest = self.buildSuggest(code: String(origin+code), value: value,type:type)
                //
//                NSLog("append====\(start)")
                queryRes.list.append(suggest)
            }
            start = start + 1
            if start > last{
                queryRes.hasNext = true
                return true
            }else {
                return false
            }
        })
        let endtime =  Date().currentTimeMillis()
        print("keyword find time:\(endtime-starttime)ms＝＝\(queryRes.list.count)")
        return queryRes
    }
    
    func buildSuggest(code:String,value:String, type:String)->Candidate {
        let value2 = value.dropFirst(); // delete one return
        return Candidate(code: code, text: String(value2), type: type)
    }
    
    static let shared = Lotus()
}
