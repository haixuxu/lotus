//
//  Trie.swift
//  inputkit
//
//  Created by xuxihai on 2022/11/23.
//

class Suggest<T> {
    var code: String
    var value: T
    var index: Int
    init(code: String, value: T, index: Int) {
        self.code = code
        self.value = value
        self.index = index
    }
    
    var description: String {
         return "(index:\(index),code:\(code), value:\(value))"
     }

}

class TrieNode<T> {
    // 一个a-z字符
    var uchar: String
    var children: [String: TrieNode] = [:]
    var isCompleteWord: Bool = false
    var data:[T]?
    
    init(uchar: String) {
        self.uchar = uchar;
//        self.isCompleteWord=isCompleted;
    }
    
}

class Trie<T> {
    
    var root: TrieNode<T>
    init() {
        self.root = TrieNode(uchar: "*")
    }
    // insert string
    public func insert(word: String, value:[T]) {
        guard !word.isEmpty else { return }
        
        var node = self.root
        var cnode:TrieNode<T>
        
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
    
    private func findLastNode(word:String)-> TrieNode<T>?{
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
    public func find(keyword: String,offset:Int8,limit:Int8) -> [Suggest<T>] {
        if keyword.isEmpty  { return [] }
        var start:Int = 0
        var output: [Suggest<T>] = []
        var finished = false;
        
        var lines = [String]()
        
        guard let lastNode = self.findLastNode(word: keyword) else{
            return output
        }
        backtrack(cnode: lastNode, paths:&lines);
        
        return output
        
        func backtrack(cnode :TrieNode<T>, paths : inout [String]){
            let data = cnode.data
            if data != nil {
                for (_,ele) in data!.enumerated(){
                    if start>=offset{
                        let code = paths.joined(separator: "")
                        let suggest = Suggest.init(code: code, value: ele, index: start)
                        output.append(suggest)
                    }
                    start = start + 1
                    if start == offset + limit{
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


