//
//  LifeComponent.swift
//  recaps
//
//  Created by Ana Poletto on 02/12/25.
//

import SwiftUI

struct CapsuleLifes: View {
    var capsule: Capsule
    
    var body: some View {
        Image(String(capsule.lives) + "Life")
    }
}

#Preview {
    CapsuleLifes(capsule:
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
                        lives: 0,
                        members: [],
                        ownerId: " ",
                        status: .inProgress))
}

