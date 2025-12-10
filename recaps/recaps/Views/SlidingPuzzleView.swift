//
//  SlidingPuzzleView.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 05/12/25.
//

//
//  SlidingPuzzleView.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 05/12/25.
//

import SwiftUI
import Lottie
import AVFoundation


struct SlidingPuzzleView: View {
    
    @State private var viewModel = SlidingPuzzleViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State var isSolved = false
    @State private var hidePuzzle = false

    var image: UIImage?
    
    var body: some View {
        
        ZStack {
            // 1. Fundo Escurecido da Tela
            Color.black.opacity(0.6) // Aumentei um pouco para dar destaque ao modal
                .ignoresSafeArea()
            
            VStack (spacing: 54) {
                VStack (spacing: 8) {
                    Text("New memory available in")
                        .font(.coveredByYourGraceSignature)
                    
                    Text(viewModel.timeUntilMidnight)
                        .font(.appTitle2)
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top, -54)
                
                // 2. O Card Flutuante
                VStack(spacing: 0) {
                    
                    Text("Daily memory")
                        .foregroundStyle(.white)
                        .font(.coveredByYourGraceTitle)
                        .padding(.top, 24)
                    
                    Text("Play to reveal the memory")
                        .foregroundStyle(.white)
                        .font(.appBody)
                        .padding(.top, 8)
                    
                    ZStack {
                        
                        if let image = image {
                            ScreenshotPrivacy {
                                SlidingPuzzleComponent(isSolved: $isSolved, image: image)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .padding()
                                .foregroundStyle(.white)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    //                .padding(.horizontal, 8)
                    
                    
                }
                .background(Color.fillDarkSecondary) // Fundo do Card
                .cornerRadius(24)
                
                .padding(.horizontal, 12)
            }
            if isSolved {
                LottieView(animation: .named("FinalGame"))
                    .playing(loopMode: .playOnce)
                    .animationSpeed(2)
                    .configure {
                        $0.contentMode = .scaleAspectFill
                    }
                    .offset(y: 30)
            }
        }
        .onChange(of: isSolved) {
            if isSolved {
                viewModel.playVictorySound()
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                hidePuzzle = true
            }
            
        }
        
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }
            
            
        }
    }
}

#Preview {
    SlidingPuzzleView()
}
