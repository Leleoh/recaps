//
//  CloseCapsule.swift
//  recaps
//
//  Created by Ana Poletto on 25/11/25.
//

import Foundation
import SwiftUI

struct CloseCapsule: View {
    var capsule: Capsule

    var body: some View {
        ZStack {
            let lastThree = Array(capsule.submissions.suffix(3))

            ZStack {
                ForEach(Array(lastThree.enumerated()), id: \.1.id) { index, submission in
                    SubmissionView(submission: submission)
                        .offset(x: CGFloat(-2 * index), y: CGFloat(-18 * index))
                        .opacity(0.9 - Double(index) * 0.25)
                }
            }
            .offset(y: 20)
            Image(.closeCapsule)
                .frame(width: 313, height: 211)
                .opacity(0.8)
        } 
    }
}






#Preview {
    let url = URL(string: "https://picsum.photos/300/200")!


    let testSubmissions = [
        Submission(id: UUID(), imageURL: url, description: "Primeira", authorId: "1", date: Date(), capsuleID: UUID()),
        Submission(id: UUID(), imageURL: url, description: "Segunda", authorId: "2", date: Date(), capsuleID: UUID()),
        Submission(id: UUID(), imageURL: url, description: "Terceira", authorId: "3", date: Date(), capsuleID: UUID())
    ]

    return CloseCapsule(
        capsule: Capsule(
            id: UUID(),
            code: "F5GX3",
            submissions: testSubmissions,
            name: "Academy",
            createdAt: Date(),
            offensive: 50,
            lastSubmissionDate: Date(),
            validOffensive: false,
            lives: 3,
            members: [],
            ownerId: " ",
            status: .inProgress
        )
    )
}
