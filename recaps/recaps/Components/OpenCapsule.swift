//
//  OpenCapsule.swift
//  recaps
//
//  Created by Ana Poletto on 25/11/25.
//

import Foundation
import SwiftUI

struct OpenCapsule: View {
    var isPink: Bool = true
    var capsule: Capsule
    
    var body: some View {
        ZStack {
            Image(isPink ? .backOpenCapsulePink : .backOpenCapsuleGreen)
                .frame(width: 313, height: 211)
                .opacity(0.8)
                .offset(x: CGFloat(0), y: CGFloat(-56))
            let lastThree = Array(capsule.submissions.suffix(3))
            ZStack {
                ForEach(Array(lastThree.enumerated()), id: \.1.id) { index, submission in
                    SubmissionView(submission: submission, height: 80, width: 110)
                        .offset(x: CGFloat(-1 * index), y: CGFloat(-10 * index))
                        .opacity(0.9 - Double(index) * 0.25)
                }
            }

            Image(isPink ? .openCapsulePink : .openCapsuleGreen)
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

    return OpenCapsule(
        isPink: false,
        capsule: Capsule(
            id: UUID(),
            code: "F5GX3",
            submissions: testSubmissions,
            name: "Academy",
            createdAt: Date(),
            offensive: 0,
            offensiveTarget: 50,
            lastSubmissionDate: Date(),
            validOffensive: false,
            lives: 3,
            members: [],
            ownerId: " ",
            status: .inProgress
        )
    )
}

