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
    
    var body: some View {
        NavigationView {
            ScrollView {
                PinterestLikeGrid($submissions, spacing: 8) { submission, index in
                    
                    if let url = submission.imageURL {
                        NavigationLink {
                            PhotoDetailView(submission: submission)
                        } label: {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Gallery")
    }
}


