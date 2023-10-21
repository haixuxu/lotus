//
//  Supplement.swift
//  Lotus
//  extension Some class
//  Created by xuxihai on 2022/11/26.
//

import Foundation


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
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
          let startingIndex = start ?? startIndex
          return index(startingIndex, offsetBy: position, limitedBy: endIndex)
      }
   
      func character(at position: Int) -> Character? {
          guard position >= 0, let indexPosition = index(at: position) else {
              return nil
          }
          return self[indexPosition]
      }
    
    static func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
     func URLEncodedString() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed);
      }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
          do {
              let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
              let range = NSRange(location: 0, length: count)
              self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
          } catch { return }
      }

}
