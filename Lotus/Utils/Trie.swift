//
//  Trie.swift
//  inputkit
//
//  Created by xuxihai on 2022/11/23.
//

import Foundation

class TrieNode: Codable {
    var children: [String: TrieNode] = [:]
    var data: [String] = []

    init(){
        
    }
}

class Trie{
    
    var root: TrieNode
    init() {
        self.root = TrieNode.init()
    }
    
    // insert string
    public func insert(word: String, value:String) {
        guard !word.isEmpty else { return }
        
        var node = self.root
        var cnode:TrieNode
        
        for (index, char) in word.enumerated() {
            let charStr = String(char)
            
            if let child = node.children[charStr] {
                node = child
            } else {
                cnode = TrieNode.init()
                node.children[charStr]=cnode
                node = cnode
            }
            
            if index == word.count-1 {
                //                node.isCompleteWord = true
                node.data.append(value)
            }
        }
    }
    
    private func findLastNode(word:String)-> TrieNode?{
        var node=self.root
        
        for (index, char) in word.enumerated() {
            let charStr = String(char)
            if let child = node.children[charStr] {
                node = child
                if index == word.count-1 {
                    return node
                }
                continue
            }
            return nil
        }
        return nil
    }
    
    // find all words with given prefix
    public func find(keyword: String,callback: (String,String)->Bool) {
        if keyword.isEmpty  { return }
        var finished = false;
        var tracks = [String]()
        
        guard let lastNode = self.findLastNode(word: keyword) else{ return }
        backtrack(cnode: lastNode, paths:&tracks);
        
        func backtrack(cnode :TrieNode, paths : inout [String]){
            let data = cnode.data
            let code = paths.joined(separator: "")
            for (index,ele) in data.enumerated(){
                if keyword.hasPrefix("zz") && keyword.count==4 && index==0{
                    continue
                }
                let completed = callback(code, ele)
                if completed {
                    finished = true
                    return
                }
                if keyword.hasPrefix("zz") && keyword.count<4 {
                    break
                }
            }
            
            if cnode.children.count == 0 {
                return
            }
            
            for i in 0..<26 {
                let charc = String(UnicodeScalar(UInt8(97+i)))
                if let child = cnode.children[charc] {
                    paths.append(charc)
                    backtrack(cnode: child, paths: &paths)
                    if finished {
                        return
                    }
                    _ = paths.popLast()
                }
            }
        }
    }
}
