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
    
    func firstWord()->String{
        var firstPart = ""
        for scalar in self.unicodeScalars {
            if scalar == " " {
                return firstPart
            } else {
                firstPart.append(String(scalar))
            }
        }
        return "zzzz"
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

    /// 将字符串中的日期/时间模板替换为当前时间值
    /// 支持: {date} → yyyy-MM-dd, {datetime} → yyyy-MM-dd HH:mm:ss, {datetime|format} → 自定义格式
    func processDateTemplates() -> String {
        guard self.contains("{") else { return self }
        var result = self
        let now = Date()

        // {datetime|format} 必须先处理（比 {datetime} 更具体）
        if let customPattern = try? NSRegularExpression(pattern: "\\{datetime\\|([^}]+)\\}") {
            let nsResult = result as NSString
            let matches = customPattern.matches(
                in: result,
                range: NSRange(location: 0, length: nsResult.length)
            ).reversed()
            for match in matches {
                guard let fullRange = Range(match.range, in: result),
                      let fmtRange = Range(match.range(at: 1), in: result) else { continue }
                let fmt = String(result[fmtRange])
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_CN")
                formatter.dateFormat = fmt
                result.replaceSubrange(fullRange, with: formatter.string(from: now))
            }
        }

        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        result = result.replacingOccurrences(of: "{datetime}", with: dtFormatter.string(from: now))

        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "yyyy-MM-dd"
        result = result.replacingOccurrences(of: "{date}", with: dFormatter.string(from: now))

        return result
    }

    /// 简体 → 繁体
    func toTraditionalChinese() -> String {
        return applyingTransform(StringTransform(rawValue: "Hans-Hant"), reverse: false) ?? self
    }

}
