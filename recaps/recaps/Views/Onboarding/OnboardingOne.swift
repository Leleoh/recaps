//
//  OnBoardingOne.swift
//  recaps
//
//  Created by Ana Poletto on 09/12/25.
//

import SwiftUI

struct OnboardingOne: View {
    var body: some View {
        ZStack {
            Image(.backgroundPNG)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 104){
                VStack(spacing: 52){
                    VStack(spacing: 8){
                        Text("Capsules keep moments")
                            .font(.title)
                        HStack(spacing: 12){
                            Text("Recapsule")
                                .font(.coveredByYourGraceTitle)
                                .foregroundStyle(.sweetNSour)
                            Text("unlocks memories")
                                .font(.title)
                        }
                    }
                    Image(.capsuleOnBoarding)
                    
                    
                }
                Text("Create shared Recapsules")
                    .font(.title2)
            }
        }
        
    }
}

#Preview {
    OnboardingOne()
}
