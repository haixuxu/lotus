//
//  types.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/27.
//

import Foundation
import SwiftUI
import Defaults
import Sparkle

enum CandidatesDirection: Int, Decodable, Encodable {
    case vertical
    case horizontal
}

enum CandidateTheme: Int, Codable, CaseIterable {
    case light
    case dark
}

extension CandidateTheme {
    var backgroundColor: Color {
        switch self {
        case .light: return Color(red: 0.98, green: 0.98, blue: 0.98)
        case .dark:  return Color(red: 0.15, green: 0.15, blue: 0.18)
        }
    }
    var textColor: Color {
        switch self {
        case .light: return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .dark:  return Color(red: 0.88, green: 0.88, blue: 0.88)
        }
    }
    var accentColor: Color {
        switch self {
        case .light: return Color(red: 0.863, green: 0.078, blue: 0.89)
        case .dark:  return Color(red: 1.0, green: 0.45, blue: 1.0)
        }
    }
    var hintColor: Color {
        switch self {
        case .light: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .dark:  return Color(red: 0.55, green: 0.55, blue: 0.6)
        }
    }
    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark:  return "深色"
        }
    }
}

struct UserPhrase: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var code: String
    var text: String
}

extension Defaults.Keys {
    static let candidatesDirection = Key<CandidatesDirection>(
        "candidatesDirection",
        default: CandidatesDirection.horizontal
    )
    static let showCodeInWindow = Key<Bool>("showCodeInWindow", default: true)
    static let wubiCodeTip = Key<Bool>("wubiCodeTip", default: true)
    static let wubiAutoCommit = Key<Bool>("wubiAutoCommit", default: false)
    static let candidateCount = Key<Int>("candidateCount", default: 6)
    static let codeStrategy = Key<CodingStrategy>("codingStrategy", default: CodingStrategy.wubiPinyin)
    // 外观
    static let candidateFontSize = Key<Int>("candidateFontSize", default: 20)
    static let candidateWindowOpacity = Key<Double>("candidateWindowOpacity", default: 1.0)
    static let candidateTheme = Key<CandidateTheme>("candidateTheme", default: .light)
    // 繁简转换
    static let outputTraditional = Key<Bool>("outputTraditional", default: false)
    // 用户自定义短语
    static let userPhrases = Key<[UserPhrase]>("userPhrases", default: [])
}

enum InputMode {
    case zhhans
    case enUS
}

struct Candidate: Hashable {
    let code: String
    let text: String
    let type: UInt8  // 0:custom,1 wb,2 py,3 sp
}

struct CandidatesData {
    var hasPrev:Bool
    var hasNext:Bool
    var list:[Candidate]
}

enum CodingStrategy: Int, CaseIterable, Decodable, Encodable {
    case wubi
    case pinyin
    case wubiPinyin
}


//var set = false

let punctution: [String: String] = [
    ",": "，",
    ".": "。",
    "/": "、",
    ";": "；",
    "'": "‘",
    "[": "［",
    "]": "］",
    "`": "｀",
    "!": "！",
    "@": "‧",
    "#": "＃",
    "$": "￥",
    "%": "％",
    "^": "……",
    "&": "＆",
    "*": "×",
    "(": "（",
    ")": "）",
    "-": "－",
    "_": "——",
    "+": "＋",
    "=": "＝",
    "~": "～",
    "{": "｛",
    "\\": "、",
    "|": "｜",
    "}": "｝",
    ":": "：",
    "\"": "“",
    "<": "《",
    ">": "》",
    "?": "？"
]
