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

struct SlidingPuzzleView: View {
    @State var isSolved = false
    
    var body: some View {
        
        VStack{
            ZStack {
                // 1. Fundo Escurecido da Tela
                Color.black.opacity(0.6) // Aumentei um pouco para dar destaque ao modal
                    .ignoresSafeArea()
                
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
                        if let image = UIImage(named: "monkey") {
                            SlidingPuzzleComponent(isSolved: $isSolved, image: image)
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
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                        .shadow(radius: 5)
                    
                    Text("Memória concluída!")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                }
                .background(.black.opacity(0.75))
                .transition(.opacity)
                .offset(y: -40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SlidingPuzzleView()
}
