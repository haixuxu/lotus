//
//  CandidatesView.swift
//  Lotus
//
//  Created by xuxihai on 2022/11/21.
//
import SwiftUI
import Defaults

func getShownCode(candidate: Candidate, origin: String) -> String {
    if candidate.code.hasPrefix(origin) && candidate.code.count > origin.count {
        let helpCount = candidate.code.count - origin.count
        let suffix = String(candidate.code.suffix(helpCount))
        return "~\(suffix)"
    }
    return ""
}

struct CandidateView: View {
    var candidate: Candidate
    var index: Int
    var origin: String
    var selected: Bool = false

    @Default(.candidateFontSize) private var fontSize
    @Default(.candidateTheme) private var theme
    @Default(.wubiCodeTip) private var wubiCodeTip

    var body: some View {
        let mainColor = selected ? theme.accentColor : theme.textColor
        let smallSize = CGFloat(max(fontSize - 2, 12))

        return HStack(alignment: .center, spacing: 4) {
            Text("\(index).")
                .frame(minWidth: 20, alignment: .trailing)
                .font(.system(size: smallSize))
                .foregroundColor(mainColor)
            Text(candidate.text)
                .font(.system(size: CGFloat(fontSize)))
                .foregroundColor(mainColor)
            if wubiCodeTip {
                Text(getShownCode(candidate: candidate, origin: origin))
                    .font(.system(size: smallSize))
                    .foregroundColor(theme.hintColor)
            }
        }
        .fixedSize()
    }
}

struct CandidatesView: View {
    var candidates: [Candidate]
    var origin: String
    var hasPrev: Bool = false
    var hasNext: Bool = false

    @Default(.candidatesDirection) var direction
    @Default(.candidateFontSize) private var fontSize
    @Default(.candidateTheme) private var theme

    var _candidatesView: some View {
        ForEach(Array(candidates.enumerated()), id: \.element) { (index, candidate) -> CandidateView in
            CandidateView(
                candidate: candidate,
                index: index + 1,
                origin: origin,
                selected: index == 0
            )
        }
    }
    
    var _indicator: some View {
            if Defaults[.candidatesDirection] == CandidatesDirection.horizontal {
                return AnyView(VStack(spacing: 0) {
                    Image(hasPrev ? "arrowUp" : "arrowUpOff")
                        .resizable()
                        .frame(width: 10, height: 10, alignment: .center)
                        .onTapGesture {
                            if !hasPrev { return }
                            NotificationCenter.default.post(
                                name: LotusTable.prevPageBtnTapped,
                                object: nil
                            )
                        }
                    Image(hasNext ? "arrowDown" : "arrowDownOff")
                        .resizable()
                        .frame(width: 10, height: 10, alignment: .center)
                        .onTapGesture {
                            if !hasNext { return }
                            print("next")
                            NotificationCenter.default.post(
                                name: LotusTable.nextPageBtnTapped,
                                object: nil
                            )
                        }
                })
            }
        return AnyView(HStack( spacing: 4) {
                Image(hasPrev ? "arrowUp" : "arrowUpOff")
                    .resizable()
                    .frame(width: 10, height: 10, alignment: .center)
                    .rotationEffect(Angle(degrees: -90), anchor: .center)
                    .onTapGesture {
                        if !hasPrev { return }
                        NotificationCenter.default.post(
                            name: LotusTable.prevPageBtnTapped,
                            object: nil
                        )
                    }
                Image(hasNext ? "arrowDown" : "arrowDownOff")
                    .resizable()
                    .frame(width: 10, height: 10, alignment: .center)
                    .rotationEffect(Angle(degrees: -90), anchor: .center)
                    .onTapGesture {
                        if !hasNext { return }
                        print("next")
                        NotificationCenter.default.post(
                            name: LotusTable.nextPageBtnTapped,
                            object: nil
                        )
                    }
            })
        }

    @Default(.showCodeInWindow) private var showCodeInWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 6, content: {
            if showCodeInWindow {
                Text(origin)
                    .font(.system(size: CGFloat(fontSize)))
                    .foregroundColor(theme.hintColor)
                    .fixedSize()
            }
            if direction == CandidatesDirection.horizontal {
                HStack(alignment: .center, spacing: 8) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    _candidatesView
                    _indicator
                }
                .fixedSize()
            }
        })
        .padding(.horizontal, 10.0)
        .padding(.vertical, 6)
        .fixedSize()
        .background(theme.backgroundColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CandidatesView(candidates: [
            Candidate(code: "a", text: "工", type: DATA_WB),
            Candidate(code: "ab", text: "戈", type: DATA_WB),
            Candidate(code: "abc", text: "啊", type: DATA_WB),
            Candidate(code: "abcg", text: "阿", type: DATA_WB),
            Candidate(code: "addd", text: "吖", type: DATA_WB),
            Candidate(code: "adde", text: "若有", type: DATA_WB),
            Candidate(code: "addf", text: "欺压", type: DATA_WB),
        ], origin: "a")
    }
}


