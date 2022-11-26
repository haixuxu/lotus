//
//  Trie.swift
//  inputkit
//
//  Created by xuxihai on 2022/11/23.
//

class TrieNode {
    // 一个a-z字符
    var uchar: String
    var children: [String: TrieNode] = [:]
    var isCompleteWord: Bool = false
    var data:[String]?
    
    init(uchar: String) {
        self.uchar = uchar;
//        self.isCompleteWord=isCompleted;
    }
    
}

class Trie{
    
    var root: TrieNode
    init() {
        self.root = TrieNode(uchar: "*")
    }
    // insert string
    public func insert(word: String, value:[String]) {
        guard !word.isEmpty else { return }
        
        var node = self.root
        var cnode:TrieNode
        
        for (index, char) in word.enumerated() {
            let charStr = String(char)

            if let child = node.children[charStr] {
                node = child
            } else {
                cnode = TrieNode(uchar: charStr)
                node.children[charStr]=cnode
                node = cnode
            }
            
            if index == word.count-1 {
                node.isCompleteWord = true
                if node.data != nil {
                    for item in value {
                        node.data!.append(item)
                    }
                }else {
                    node.data = value
                }
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
            if data != nil {
                let code = paths.joined(separator: "")
                for (_,ele) in data!.enumerated(){
                    let completed = callback(code, ele)
                    if completed {
                        finished = true
                        return
                    }
                }
            }
            
            if cnode.children.count == 0 {
                return
            }
            
            for i in 0..<26 {
                let charc = String(UnicodeScalar(UInt8(97+i)))
                if let child = cnode.children[charc] {
                    paths.append(child.uchar)
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
