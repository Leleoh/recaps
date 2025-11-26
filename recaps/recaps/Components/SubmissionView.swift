//
//  SubmissionView.swift
//  recaps
//
//  Created by Ana Poletto on 25/11/25.
//

import Foundation
import SwiftUI


struct SubmissionView: View {
    var submission: Submission
    var height: CGFloat = 120
    var width: CGFloat = 160
    var body: some View {
        if let url = submission.imageURL,
           let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
        } else {
            Color.gray
                .frame(width: width, height: height)
        }
    }
}

#Preview {
    let url = URL(string: "https://picsum.photos/300/200")!

    let testSubmissions = Submission(id: UUID(), imageURL: url, description: "Primeira", authorId: "1", date: Date(), capsuleID: UUID())
    SubmissionView(submission: testSubmissions)
}
