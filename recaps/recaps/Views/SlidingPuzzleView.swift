//
//  SlidingPuzzleView.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 05/12/25.
//

import SwiftUI

struct SlidingPuzzleView: View {
    var body: some View {
        
        //zstack que engloba tudo
        ZStack{
            
            RoundedRectangle(cornerRadius: 24)
//                .frame(width: 350, height: 440)
                .padding(.horizontal, 12)
                
            
            VStack{
                
                Spacer()
                
                Text("Daily memory")
                    .foregroundStyle(.black)
                    .font(.coveredByYourGraceTitle)
                    .padding(.top, 12)
                
                
                Text("Play to reveal the memory")
                    .foregroundStyle(.black)
                    .font(.appBody)
                    .padding(.top, 12)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.red)
                    
                    SlidingPuzzleComponent(image: UIImage(named: "monkey")!)
                }
               
                .padding(.horizontal, 22)

            }
            
            
            
            
        }
        .padding(.top, 211)
        
        
    }
}

#Preview {
    SlidingPuzzleView()
}
