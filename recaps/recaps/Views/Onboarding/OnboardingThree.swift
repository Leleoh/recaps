//
//  OnboardingThree.swift
//  recaps
//
//  Created by Ana Poletto on 09/12/25.
//

import SwiftUI

struct OnboardingThree: View {
    var body: some View {
        ZStack {
            Image(.backgroundPNG)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 15){
                Image(.photoOnboarding)
                    .resizable()
                    .ignoresSafeArea()
                Text("Play to spy on saved memories")
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 90)
        }
        
    }
}

#Preview {
    OnboardingThree()
}
