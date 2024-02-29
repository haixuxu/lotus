//
//  Lotus.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/21.
//

import Foundation
import Cocoa
import InputMethodKit
import Sparkle
import Defaults

let prefixType:[String:String] = ["0":"user", "1":"wb", "2":"py","3":"sp"]

class LotusTable: NSObject {
    
    static let nextPageBtnTapped = Notification.Name("LotusTable.nextPageBtnTapped")
    static let prevPageBtnTapped = Notification.Name("LotusTable.prevPageBtnTapped")
    
    private var dataTree:Trie?=nil
    private var suggestCount:Int = 6
    private var strategy:CodingStrategy = CodingStrategy.wubiPinyin
    var canUsed: Bool {
        get {
            if(dataTree==nil){
                return false
            }else{
                return true;
            }
        }
    }
    
    override init() {
        super.init()
        self.suggestCount = Defaults[.candidateCount]
        self.strategy = Defaults[.codeStrategy]
        NSLog("[LotusTable] Config==:\(self.strategy),\(self.suggestCount)")
        
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
        Utils.parseDictKeyValue(dictfile: "userdict", callback:  { (word, list) in
            list.forEach { item in
                dataTree!.insert(word: word, value:String("0"+item) )
            }
        })
        var wbmap = [String: String]()
        Utils.parseDictKeyValue(dictfile: "wb_table", callback:  { (word, list) in
            list.forEach { item in
                wbmap[String(item)]=word
                dataTree!.insert(word: word, value:String("1"+item) )
            }
        })
        Utils.parseDictKeyValue(dictfile: "py_table", callback:  { (word, list) in
            list.forEach { item in
                if let wb_word = wbmap[String(item)] {
                    dataTree!.insert(word: word, value: String("2\(item)(\(wb_word))"))
                    // now val is not nil and the Optional has been unwrapped, so use it
                }else {
                    dataTree!.insert(word: word, value:String("2"+item) )
                }
                
            }
        })
        Utils.parseDictKeyValue(dictfile: "sp_table", callback:  { (word, list) in
            list.forEach { item in
                dataTree!.insert(word: word, value:String("3"+item) )
            }
        })
        
        let endtime =  Date().currentTimeMillis()
        
        print("[LotusTable] build dict index time:\(endtime-starttime)ms")
    }
    
    
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
    
    static let shared = LotusTable()
}
