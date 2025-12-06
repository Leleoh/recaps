//
//  Key.swift
//  recaps
//
//  Created by Ana Poletto on 27/11/25.
//

import SwiftUI
struct Key: View {
    var capsule: Capsule
    
    var body: some View {
            Image(capsule.validOffensive ? .orange : .gray)
                .frame(width: 20, height: 46)
    }
}

#Preview {
    Key(capsule:
            Capsule(
        id: UUID(),
        code: "F5GX3",
        submissions: [],
        name: "Academy",
        createdAt: Date(),
        offensive: 0,
        offensiveTarget: 50,
        lastSubmissionDate: Date(),
        validOffensive: true,
        lives: 3,
        members: [],
        ownerId: " ",
        status: .inProgress,
        blacklisted: []))
}
