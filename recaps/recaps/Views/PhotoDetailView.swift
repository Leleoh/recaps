//
//  PhotoDetailView.swift
//  recaps
//
//  Created by Ana Poletto on 03/12/25.
//

import SwiftUI

struct PhotoDetailView: View {
    let submission: Submission
    let num = Int.random(in: 1...5)
    @State private var viewModel = PhotoDetailsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    ZStack(alignment: .topLeading){
                        AsyncImage(url: submission.imageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(.degrees(-2))
                                .shadow(radius: 20)
                        } placeholder: {
                            ProgressView()
                        }
                        Pins(pin: num)
                            .scaleEffect(2)
                            .padding(.top, -10)
                            .padding(.leading, 30)
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("by " + "\(viewModel.userName)")
                            .font(.coveredByYourGraceSignature)
                        
                        Text(viewModel.formatDate(submission.date))
                            .font(.coveredByYourGraceSignature)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Text(submission.description ?? "")
                    .font(.coveredByYourGraceTitle)
            }
            .padding(.horizontal, 44)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if let image = viewModel.shareableImage {
                        let swiftUIImage = Image(uiImage: image)
                        
                        ShareLink(
                            item: swiftUIImage,
                            preview: SharePreview("Achievement!", image: swiftUIImage)
                        )  {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 48, height: 48)
                        .tint(.black)
                        .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 100))
                        .padding(.trailing, 26)
                        .padding(.bottom, 26)
                    }
                }
            }
        }
        .task {
            if let name = await viewModel.getUser(id: submission.authorId) {
                viewModel.userName = name
            }
            
            if let url = submission.imageURL {
                await viewModel.loadShareableImage(from: url)
            }
        }
    }
}

#Preview {
    let url = URL(string: "https://picsum.photos/300/200")!
    
    let testSubmissions = Submission(
        id: UUID(),
        imageURL: url,
        description: "Primeira",
        authorId: "1",
        date: Date(),
        capsuleID: UUID()
    )
    
    PhotoDetailView(submission: testSubmissions)
}
