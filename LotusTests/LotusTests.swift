//
//  LotusTests.swift
//  LotusTests
//
//  Created by xuxihai on 2022/11/19.
//

import XCTest
@testable import Lotus

final class LotusTests: XCTestCase {

    // MARK: - Trie 基础测试

    func testTrieInsertAndFind() {
        let trie = Trie()
        trie.insert(word: "a", value: NodeData(type: 1, value: "a 工"))
        trie.insert(word: "ab", value: NodeData(type: 1, value: "ab 戈"))
        trie.insert(word: "abc", value: NodeData(type: 1, value: "abc 大"))

        var results: [String] = []
        trie.find(keyword: "a") { _, item in
            results.append(item.value)
            return false
        }
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results.contains("a 工"))
        XCTAssertTrue(results.contains("ab 戈"))
        XCTAssertTrue(results.contains("abc 大"))
    }

    func testTrieExactMatch() {
        let trie = Trie()
        trie.insert(word: "abc", value: NodeData(type: 1, value: "abc 大"))

        var found = false
        trie.find(keyword: "abc") { _, _ in
            found = true
            return false
        }
        XCTAssertTrue(found)
    }

    func testTrieFindNoMatch() {
        let trie = Trie()
        trie.insert(word: "abc", value: NodeData(type: 1, value: "abc 大"))

        var count = 0
        trie.find(keyword: "xyz") { _, _ in
            count += 1
            return false
        }
        XCTAssertEqual(count, 0)
    }

    func testTrieEmptyKeyword() {
        let trie = Trie()
        trie.insert(word: "abc", value: NodeData(type: 1, value: "abc 大"))

        var count = 0
        trie.find(keyword: "") { _, _ in
            count += 1
            return false
        }
        XCTAssertEqual(count, 0, "空关键词不应返回任何结果")
    }

    func testTrieEarlyStop() {
        let trie = Trie()
        trie.insert(word: "a", value: NodeData(type: 1, value: "a 工"))
        trie.insert(word: "ab", value: NodeData(type: 1, value: "ab 戈"))
        trie.insert(word: "abc", value: NodeData(type: 1, value: "abc 大"))

        var count = 0
        trie.find(keyword: "a") { _, _ in
            count += 1
            return count >= 1  // 找到第一个就停止
        }
        XCTAssertEqual(count, 1, "回调返回 true 时应提前停止遍历")
    }

    func testTrieMultipleValuesPerNode() {
        let trie = Trie()
        trie.insert(word: "a", value: NodeData(type: 1, value: "a 工"))
        trie.insert(word: "a", value: NodeData(type: 2, value: "a 阿"))

        var results: [String] = []
        trie.find(keyword: "a") { _, item in
            results.append(item.value)
            return false
        }
        XCTAssertEqual(results.count, 2)
    }

    // MARK: - 日期模板测试

    func testDateTemplateDate() {
        let result = "{date}".processDateTemplates()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        XCTAssertEqual(result, formatter.string(from: Date()))
    }

    func testDateTemplateDatetime() {
        let result = "{datetime}".processDateTemplates()
        // 只验证格式，不精确匹配秒
        let pattern = #"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$"#
        XCTAssertTrue(result.range(of: pattern, options: .regularExpression) != nil,
                      "期望格式 yyyy-MM-dd HH:mm:ss，实际: \(result)")
    }

    func testDateTemplateCustomFormat() {
        let result = "{datetime|yyyy年MM月dd日}".processDateTemplates()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        XCTAssertEqual(result, formatter.string(from: Date()))
    }

    func testDateTemplateNoTemplate() {
        let original = "没有模板的普通文字"
        XCTAssertEqual(original.processDateTemplates(), original)
    }

    func testDateTemplateMixed() {
        let result = "今天是{date}，现在是{datetime|HH:mm}".processDateTemplates()
        XCTAssertFalse(result.contains("{date}"))
        XCTAssertFalse(result.contains("{datetime|HH:mm}"))
    }

    // MARK: - 繁简转换测试

    func testTraditionalConversion() {
        XCTAssertEqual("爱".toTraditionalChinese(), "愛")
        XCTAssertEqual("国".toTraditionalChinese(), "國")
        XCTAssertEqual("汉字".toTraditionalChinese(), "漢字")
    }

    func testTraditionalConversionAlreadyTraditional() {
        // 繁体字不应被改变
        let traditional = "愛國"
        XCTAssertEqual(traditional.toTraditionalChinese(), traditional)
    }

    func testTraditionalConversionEnglish() {
        // 英文不受影响
        XCTAssertEqual("Hello".toTraditionalChinese(), "Hello")
    }

    // MARK: - UserPhrase 测试

    func testUserPhraseIsIdentifiable() {
        let p1 = UserPhrase(code: "mail", text: "test@example.com")
        let p2 = UserPhrase(code: "mail", text: "test@example.com")
        XCTAssertNotEqual(p1.id, p2.id, "每个 UserPhrase 应有唯一 ID")
    }

    func testUserPhraseEncoding() throws {
        let phrase = UserPhrase(code: "addr", text: "北京市")
        let data = try JSONEncoder().encode(phrase)
        let decoded = try JSONDecoder().decode(UserPhrase.self, from: data)
        XCTAssertEqual(decoded.code, phrase.code)
        XCTAssertEqual(decoded.text, phrase.text)
        XCTAssertEqual(decoded.id, phrase.id)
    }
}
