//
//  PhrasesPane.swift
//  Lotus
//

import Foundation
import SwiftUI
import Preferences
import Defaults

struct PhrasesPane: View {
    @Default(.userPhrases) private var phrases
    @State private var newCode: String = ""
    @State private var newText: String = ""
    @State private var editingID: UUID? = nil
    @State private var showAddRow: Bool = false

    var body: some View {
        Preferences.Container(contentWidth: 500.0) {
            Preferences.Section(title: "") {
                VStack(alignment: .leading, spacing: 12) {

                    HStack {
                        Text("快捷短语")
                            .font(.headline)
                        Spacer()
                        Button(action: { showAddRow.toggle() }) {
                            Image(systemName: showAddRow ? "minus.circle" : "plus.circle")
                            Text(showAddRow ? "取消" : "添加")
                        }
                    }

                    if showAddRow {
                        HStack(spacing: 8) {
                            TextField("编码（如 mail）", text: $newCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                            TextField("短语内容", text: $newText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("确认") {
                                let code = newCode.trimmingCharacters(in: .whitespaces)
                                let text = newText.trimmingCharacters(in: .whitespaces)
                                guard !code.isEmpty, !text.isEmpty else { return }
                                phrases.append(UserPhrase(code: code, text: text))
                                newCode = ""
                                newText = ""
                                showAddRow = false
                            }
                            .disabled(newCode.isEmpty || newText.isEmpty)
                        }
                        .padding(.bottom, 4)

                        Text("提示：编码支持字母，短语内容支持 {date} {datetime} {datetime|yyyy年MM月dd日} 等模板")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if phrases.isEmpty {
                        Text("暂无自定义短语，点击右上角「添加」新建")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        List {
                            ForEach(phrases) { phrase in
                                PhraseRow(
                                    phrase: phrase,
                                    isEditing: editingID == phrase.id,
                                    onEdit: { editingID = phrase.id },
                                    onSave: { newPhrase in
                                        if let idx = phrases.firstIndex(where: { $0.id == newPhrase.id }) {
                                            phrases[idx] = newPhrase
                                        }
                                        editingID = nil
                                    },
                                    onCancel: { editingID = nil }
                                )
                            }
                            .onDelete { indexSet in
                                phrases.remove(atOffsets: indexSet)
                            }
                        }
                        .frame(height: min(CGFloat(phrases.count) * 44 + 8, 300))
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                    }

                    Spacer(minLength: 10)
                }
            }
        }
    }
}

private struct PhraseRow: View {
    let phrase: UserPhrase
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: (UserPhrase) -> Void
    let onCancel: () -> Void

    @State private var editCode: String = ""
    @State private var editText: String = ""

    var body: some View {
        if isEditing {
            HStack(spacing: 8) {
                TextField("编码", text: $editCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 110)
                TextField("短语", text: $editText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("保存") {
                    var updated = phrase
                    updated.code = editCode.trimmingCharacters(in: .whitespaces)
                    updated.text = editText.trimmingCharacters(in: .whitespaces)
                    onSave(updated)
                }
                .disabled(editCode.isEmpty || editText.isEmpty)
                Button("取消") { onCancel() }
            }
            .onAppear {
                editCode = phrase.code
                editText = phrase.text
            }
        } else {
            HStack {
                Text(phrase.code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 110, alignment: .leading)
                Text(phrase.text)
                    .lineLimit(1)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct PhrasesPane_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesPane()
    }
}
