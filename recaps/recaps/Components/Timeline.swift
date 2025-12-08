//
//  Timeline.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI

struct Timeline: View {
    var sortedMonths: [String]
    var groupedByMonth: [String: [Submission]]

    @State private var currentMonth: String = ""
    @State private var scrollOffset: CGFloat = 0

    private let estimatedImageHeight: CGFloat = 180
    private let gridColumns: Int = 2
    private let gridSpacing: CGFloat = 16

    private var allSubmissions: [Submission] {
        sortedMonths.flatMap { groupedByMonth[$0] ?? [] }
    }

    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                Gallery(submissions: allSubmissions)
                ZStack(alignment: .leading) {

                    Rectangle()
                        .fill(.white)
                        .frame(width: 4)
                        .offset(x: 8)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(sortedMonths, id: \.self) { month in
                            if month != sortedMonths.last {

                                let height = estimatedHeight(for: month)

                                HStack(spacing: 6) {
                                    Rectangle()
                                        .fill(currentMonth == month ? .sweetNSour : .white)
                                        .frame(
                                            width: currentMonth == month ? 22 : 15,
                                            height: currentMonth == month ? 8 : 4
                                        )
                                        .cornerRadius(8)

                                    Text(month.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(90))
                                }
                                .padding(.bottom, height)
                            }
                        }
                    }
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onAppear {
            currentMonth = sortedMonths.first ?? ""
        }
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            scrollOffset = value
            DispatchQueue.main.async {
                updateCurrentMonth()
            }
        }
    }

    // MARK: - Estimated Height
    private func estimatedHeight(for month: String) -> CGFloat {
        let count = groupedByMonth[month]?.count ?? 0
        let rows = ceil(Double(count) / Double(gridColumns))

        return (CGFloat(rows) * estimatedImageHeight)
             + (CGFloat(max(0, Int(rows) - 1)) * gridSpacing)
    }

    private func updateCurrentMonth() {
        let scroll = abs(scrollOffset)

        var accumulated: CGFloat = 0

        for month in sortedMonths {
            let height = estimatedHeight(for: month)
            accumulated += height

            if scroll < accumulated {
                currentMonth = month
                break
            }
        }
    }
}

// MARK: - PreferenceKey
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
