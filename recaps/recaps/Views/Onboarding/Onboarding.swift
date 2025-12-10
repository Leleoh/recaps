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
                    if index != 0 {
                        Button {
                            index -= 1
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 48, height: 48)
                                    .tint(.black.opacity(0.35))
                                    .clipShape(Circle())
                                    .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 24))
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }

                    Spacer()

                    Button {
                        if index < 2 {
                            index += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 48, height: 48)
                                .tint(.black.opacity(0.35))
                                .clipShape(Circle())
                                .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 24))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    Onboarding()
}
