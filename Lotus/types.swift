//
//  types.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/27.
//

import Foundation
import Defaults
import Sparkle

enum CandidatesDirection: Int, Decodable, Encodable {
    case vertical
    case horizontal
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
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
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
