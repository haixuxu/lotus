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

let DATA_WB:UInt8=1
let DATA_PY:UInt8=2

class LotusTable: NSObject {
    
    static let nextPageBtnTapped = Notification.Name("LotusTable.nextPageBtnTapped")
    static let prevPageBtnTapped = Notification.Name("LotusTable.prevPageBtnTapped")
    
    private var dataTree:Trie?=nil
    private var suggestCount:Int = 6
    private var strategy:CodingStrategy = CodingStrategy.wubiPinyin
    private var wbmap = [String: String]()
    private var setupwbmap=false
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
    
    public func buildWbReserve(){
        if self.setupwbmap {
            return
        }
        self.setupwbmap=true
        Utils.parseDictLine(dictfile: "wb_table", callback:  { (line) in
            let word = line.firstWord()
            Utils.split(str: line, callback: { (index,part) in
                if index>0{
                    self.wbmap[part]=word
                }
            })
        })
    }
    public func buildDictTrie() {
        
        self.dataTree = Trie.init()
        let starttime =  Date().currentTimeMillis()
        Utils.parseDictLine(dictfile: "userdict", callback:  { (line) in
            let word = line.firstWord()
            let dataiem = NodeData(type: 0, value: line)
            dataTree!.insert(word: word, value: dataiem)
        })
        
        Utils.parseDictLine(dictfile: "wb_table", callback:  { (line) in
            let word = line.firstWord()
            let dataiem = NodeData(type: DATA_WB, value: line)
            dataTree!.insert(word: word, value: dataiem)
        })
        Utils.parseDictLine(dictfile: "py_table", callback:  { (line) in
            let word = line.firstWord()
            let dataiem = NodeData(type: DATA_PY, value: line)
            dataTree!.insert(word: word, value: dataiem)
        })
        Utils.parseDictLine(dictfile: "sp_table", callback:  { (line) in
            let word = line.firstWord()
            let dataiem = NodeData(type: 3, value: line)
            dataTree!.insert(word: word, value: dataiem)
        })
        
        let endtime =  Date().currentTimeMillis()
        NSLog("[LotusTable] build dict index time:\(endtime-starttime)ms，\(dataTree!.root.children.count)")
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
        var idx = 0;
        let start = (page - 1) * limit
        let end = start + limit
        let starttime =  Date().currentTimeMillis()
        NSLog("start:\(start),===\(end)")
        self.dataTree?.find(keyword: origin, callback:  { (code, dataItem) in
            if self.strategy == CodingStrategy.wubi && dataItem.type==DATA_PY {
                return false;
            }
            if self.strategy == CodingStrategy.pinyin && dataItem.type==DATA_WB {
                return false;
            }
            let linestr = dataItem.value.trimmingCharacters(in: .whitespacesAndNewlines)
            //            NSLog("call node===\(linestr)")
            
            let parts = linestr.split(separator: " ")
            for (index,value) in parts.enumerated(){
                if index==0{
                    continue
                }
                if origin.hasPrefix("zz") && origin.count==4 && index==1{
                    continue
                }
                idx = idx + 1
                
                
                if idx <= start {
                    continue
                }
                var value2:String=String(value)
                if dataItem.type==DATA_PY {
                    if let  wubicode = self.wbmap[value2]{
                        value2 = String("\(value)(\(wubicode))")
                    }
                }
                let suggest = self.buildSuggest(code: String(origin+code), value: value2,type:dataItem.type)
                queryRes.list.append(suggest)
                if idx==end{
                    queryRes.hasNext = true
                    return true
                }
                
                if origin.hasPrefix("zz") && origin.count<4 {
                    break
                }
            }
            
            return false
        })
        let endtime =  Date().currentTimeMillis()
        print("keyword find time:\(endtime-starttime)ms＝＝\(queryRes.list.count)")
        return queryRes
    }
    
    func buildSuggest(code:String,value:String, type:UInt8)->Candidate {
        return Candidate(code: code, text: value, type: type)
    }
    
    static let shared = LotusTable()
}
