//
//  OnboardingTwo.swift
//  recaps
//
//  Created by Ana Poletto on 09/12/25.
//

import SwiftUI

struct OnboardingTwo: View {
    var body: some View {
        ZStack {
            Image(.backgroundPNG)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                ZStack(alignment: .top){
                    Image(.keyOnboarding)
                    Image(.photo1)
                        .padding(.top, 60)
                    Image(.photo2)
                        .offset(x: -60, y: 200)
                    Image(.photo3)
                        .offset(x: 90, y: 200)
                    Image(.photo4)
                        .offset(x: -90, y: 320)
                    Image(.photo5)
                        .offset(x: 70, y: 430)
                }
                .padding(.top, -40)
                Text("Save memories daily to generate the key that opens your Recapsule")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 70)
        }

    }
}

#Preview {
    OnboardingTwo()
}
