//
//  Gallery.swift
//  recaps
//
//  Created by Ana Poletto on 03/12/25.
//

import SwiftUI
import PinterestLikeGrid

struct Gallery: View {
    @State var submissions: [Submission] = []
    @State private var pinOffsets: [UUID: CGFloat] = [:]
    
    var body: some View {
        PinterestLikeGrid($submissions, spacing: 16) { submission, index in
            if let url = submission.imageURL {
                NavigationLink {
                    PhotoDetailView(submission: submission)
                } label: {
                    ZStack(alignment: .topLeading){
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Pins()
                            .scaleEffect(1.4)
                            .offset(
                                x: pinOffsets[submission.id] ?? 0,
                                y: -10
                            )
                            .onAppear {
                                if pinOffsets[submission.id] == nil {
                                    pinOffsets[submission.id] = CGFloat.random(in: -15...130)
                                }
                            }
                    }
                }
            }
        }
    }
}



