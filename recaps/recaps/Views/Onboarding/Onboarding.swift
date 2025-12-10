//
//  Onboarding.swift
//  recaps
//
//  Created by Ana Poletto on 09/12/25.
//

import SwiftUI
struct Onboarding: View {
    @State private var index = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            if index == 0 {
                OnboardingOne()
            } else if index == 1 {
                OnboardingTwo()
            } else {
                OnboardingThree()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("Skip")
                            .foregroundColor(.primary)
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    if index == 0{ EmptyView()} else {
                        Button {
                            if index > 0 {
                                index -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.black.opacity(0.5))
                        .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 32))
                        
                    }
                    Spacer()
 
                    Button {
                        if index < 2 {
                            index += 1
                        }
                        if index == 2{
                            hasSeenOnboarding = true
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black.opacity(0.5))
                    .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 32))
                }
            }
            .padding()
        }
    }
}

#Preview {
    Onboarding()
}
