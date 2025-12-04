//
//  PhotoDetailView.swift
//  recaps
//
//  Created by Ana Poletto on 03/12/25.
//
import SwiftUI

struct PhotoDetailView: View {
    let submission: Submission
    
    var body: some View {
        VStack {
            AsyncImage(url: submission.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            Text(submission.description ?? "")
            Text(submission.date, style: .date)
        }
        .padding()
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
}
