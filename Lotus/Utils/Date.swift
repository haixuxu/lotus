//
//  Date.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/26.
//

import Foundation

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
