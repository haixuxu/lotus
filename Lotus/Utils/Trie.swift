//
//  Trie.swift
//  inputkit
//
//  Created by xuxihai on 2022/11/23.
//

import Foundation

struct NodeData{
    var type:UInt8
    var value:String
}

class TrieNode {
    var children: [Character: TrieNode] = [:]
    var data: [NodeData] = []
}

class Trie{
    
    var root: TrieNode
    init() {
        self.root = TrieNode.init()
    }
    
    // insert string
    public func insert(word: String, value:NodeData) {
        guard !word.isEmpty else { return }
        
        var node = self.root
        var cnode:TrieNode
        
        for char in word {
            if let child = node.children[char] {
                node = child
            } else {
                cnode = TrieNode.init()
                node.children[char]=cnode
                node = cnode
            }
        }
        node.data.append(value)
    }
    
    private func findLastNode(word:String)-> TrieNode?{
        var node=self.root
        
        for (index, char) in word.enumerated() {
            if let child = node.children[char] {
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
    public func find(keyword: String,callback: (String,NodeData)->Bool) {
        if keyword.isEmpty  { return }
        var finished = false;
        var tracks = [Character]()
        
        guard let lastNode = self.findLastNode(word: keyword) else{ return }
        backtrack(cnode: lastNode, paths:&tracks);
        
        func backtrack(cnode :TrieNode, paths : inout [Character]){
            let data = cnode.data
            let code = String(paths)
            for item in data{
                let completed = callback(code,item)
                if completed {
                    finished = true
                    return
                }
                
            }
            
            if cnode.children.count == 0 {
                return
            }
            
            for i in 0..<26 {
                let charc = Character(UnicodeScalar(97+i)!)
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
