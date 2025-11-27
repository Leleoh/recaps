//
//  ActivityRing.swift
//  recaps
//
//  Created by Ana Poletto on 27/11/25.
//

import SwiftUI

struct ActivityRing: View {
    var capsule: Capsule
    
    private var progress: Double {
        Double(capsule.offensive) / Double(capsule.offensiveTarget)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    .sweetNSour.opacity(0.2),
                    style: StrokeStyle(lineWidth: 10)
                )
                .frame(width: 85, height: 85)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.sweetNSour,
                    
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 85, height: 85)
                .animation(.easeInOut(duration: 0.6), value: progress)
            
            Image(.orange)
        }
    }
}


#Preview {
    ActivityRing(capsule:
                    Capsule(
                        id: UUID(),
                        code: "F5GX3",
                        submissions: [],
                        name: "Academy",
                        createdAt: Date(),
                        offensive: 2,
                        offensiveTarget: 50,
                        lastSubmissionDate: Date(),
                        validOffensive: false,
                        lives: 3,
                        members: [],
                        ownerId: " ",
                        status: .inProgress))
}
