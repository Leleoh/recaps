//
//  PostOpenedCapsuleView.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI
import Lottie

struct PostOpenedCapsuleView: View {
    var capsule: Capsule
    
    @State var viewModel: PostOpenedCapsuleViewModel
    
    @State var showLottie = true
    
    var submissions: [Submission] {
        viewModel.submissions
    }
    
    var body: some View {
        ZStack {
            Image(.backgroundPNG)
                .resizable()
                .ignoresSafeArea()
            
            if showLottie {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    LottieView(animation: .named("OpenCapsule"))
                        .playing(loopMode: .playOnce)
                        .configure {
                            $0.contentMode = .scaleAspectFill
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                withAnimation {
                                    showLottie = false
                                }
                            }
                        }
                }
            } else {
                
                if !viewModel.isLoading {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            VStack(spacing: 5) {
                                Text(viewModel.dates(submissions: submissions))
                                    .font(.coveredByYourGraceSignature)
                                
                                NameComponent(text: .constant(capsule.name))
                            }
                            
                            Gallery(submissions: submissions)
                        }
                        .padding(.bottom, -40)
                        .padding(.horizontal, 24)
                    }
                } else {
                    ProgressView()
                        .controlSize(ControlSize.large)
                        .tint(Color.white)
                }
            }
        }
        
        .onAppear() {
            Task {
                if viewModel.submissions.isEmpty {
                    try await viewModel.fetchSubmissions()
                }
            }
        }
    }
}
