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
    var scrollOffset: CGFloat

    @State private var monthFrames: [String: CGRect] = [:]
    @State private var scrollIndicatorOffset: CGFloat = 0

    private var allSubmissions: [Submission] {
        sortedMonths.flatMap { groupedByMonth[$0] ?? [] }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Galeria
            Gallery(submissions: allSubmissions)

            // Timeline
            ZStack(alignment: .topLeading) {

                Rectangle()
                    .fill(.white)
                    .frame(width: 4)
                    .offset(x: 8)

                VStack(spacing: 0) {
                    ForEach(sortedMonths, id: \.self) { month in
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 15, height: 4)
                                .cornerRadius(8)

                            Text(month.capitalized)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                        }
                        .padding(.bottom, 32)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: MonthFrameKey.self,
                                        value: [month: geo.frame(in: .global)]
                                    )
                            }
                        )
                    }
                }

                Rectangle()
                    .fill(Color.sweetNSour)
                    .frame(width: 22, height: 8)
                    .cornerRadius(8)
                    .offset(y: scrollIndicatorOffset)
                    .animation(.easeInOut(duration: 0.15), value: scrollIndicatorOffset)
            }
        }
        .onPreferenceChange(MonthFrameKey.self) { frames in
            monthFrames = frames
            updateIndicator()
        }
        .onChange(of: scrollOffset) {
            updateIndicator()
        }
    }

    private func updateIndicator() {
        guard
            let firstMonth = sortedMonths.first,
            let firstFrame = monthFrames[firstMonth]
        else { return }

        let currentScrollPosition = abs(scrollOffset) + 200

        for month in sortedMonths {
            if let frame = monthFrames[month] {
                if currentScrollPosition < frame.maxY {
                    scrollIndicatorOffset = frame.minY - firstFrame.minY
                    break
                }
            }
        }
    }
}


struct MonthFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Scroll PreferenceKey
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
