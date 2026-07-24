//
//  AppearancePane.swift
//  Lotus
//

import Foundation
import SwiftUI
import Preferences
import Defaults

struct AppearancePane: View {
    @Default(.candidateFontSize) private var fontSize
    @Default(.candidateWindowOpacity) private var opacity
    @Default(.candidateTheme) private var theme
    @Default(.outputTraditional) private var outputTraditional

    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "") {
                VStack(alignment: .leading, spacing: 18) {

                    Text("候选窗口外观")
                        .font(.headline)

                    HStack {
                        Text("字号")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(fontSize) },
                            set: { fontSize = Int($0) }
                        ), in: 12...32, step: 1)
                        .frame(width: 180)
                        Text("\(fontSize) pt")
                            .frame(width: 40)
                    }

                    HStack {
                        Text("透明度")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $opacity, in: 0.5...1.0, step: 0.05)
                            .frame(width: 180)
                        Text(String(format: "%.0f%%", opacity * 100))
                            .frame(width: 40)
                    }

                    HStack {
                        Text("主题")
                            .frame(width: 60, alignment: .leading)
                        Picker("", selection: $theme) {
                            ForEach(CandidateTheme.allCases, id: \.self) { t in
                                Text(t.displayName).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                        Spacer()
                    }

                    // 预览
                    HStack {
                        Text("预览")
                            .frame(width: 60, alignment: .leading)
                        CandidatePreview()
                    }

                    Divider()

                    Text("输出")
                        .font(.headline)

                    HStack {
                        Toggle("输出繁体字", isOn: $outputTraditional)
                        Spacer(minLength: 50)
                    }

                    Spacer(minLength: 10)
                }
            }
        }
    }
}

/// 简单预览候选词窗口样式
private struct CandidatePreview: View {
    @Default(.candidateFontSize) private var fontSize
    @Default(.candidateTheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(["工", "戈", "大"].enumerated()), id: \.offset) { idx, word in
                HStack(spacing: 3) {
                    Text("\(idx + 1).")
                        .font(.system(size: CGFloat(max(fontSize - 2, 12))))
                        .foregroundColor(idx == 0 ? theme.accentColor : theme.textColor)
                    Text(word)
                        .font(.system(size: CGFloat(fontSize)))
                        .foregroundColor(idx == 0 ? theme.accentColor : theme.textColor)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(theme.backgroundColor)
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct AppearancePane_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePane()
    }
}
