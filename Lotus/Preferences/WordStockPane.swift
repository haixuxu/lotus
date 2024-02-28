//
//  WordStockPane.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/26.
//

import Foundation

import SwiftUI
import Preferences

struct WordStockPane: View {
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "") {
                Button(action: {
                    LotusTable.shared.buildDictTrie()
                }, label: {
                    Text("重建索引")
                })
            }
        }
    }
}

struct WordStockPane_Previews: PreviewProvider {
    static var previews: some View {
        WordStockPane()
    }
}
