//
//  PostOpenedCapsuleView.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI

struct PostOpenedCapsuleView: View {
    var capsule: Capsule
    let viewModel = PostOpenedCapsuleViewModel()
    
    var submissions: [Submission] {
        viewModel.orderSubmission(submissions: capsule.submissions)
    }

    var body: some View {
        ZStack {
            Image(.backgroundPNG)
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16){
                    VStack(spacing: 5) {
                        Text(viewModel.dates(submissions: submissions))
                            .font(.coveredByYourGraceSignature)
                        
                        NameComponent(text: .constant(capsule.name))
                    }
                    Gallery(submissions: submissions)
                }
                .padding(.top, -40)
                .padding(.horizontal, 24)
            }
        }
    }
}


#Preview {
    var capsule = Capsule(
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
        status: .inProgress)
    PostOpenedCapsuleView(capsule: capsule)
}
