//
//  PostOpenedCapsuleView.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI
import Lottie
import CoreHaptics

struct PostOpenedCapsuleView: View {
    var capsule: Capsule
    
    @State var viewModel: PostOpenedCapsuleViewModel
    
    @State var showLottie = true
    
    @State private var engine: CHHapticEngine?
    
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
                            prepareHaptics()
                            playSoftContinuousHaptic(duration: 4.0)
                            
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
    
    // MARK: - Core Haptics Setup
    
    // Prepara o motor háptico do dispositivo
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Erro ao iniciar haptics: \(error.localizedDescription)")
        }
    }
    
    // Toca uma vibração contínua e suave
    func playSoftContinuousHaptic(duration: TimeInterval) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // Intensidade (0.0 a 1.0) e Nitidez (Sharpness) baixas criam o efeito "Soft"
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous, // Tipo contínuo para sustentar a vibração
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Erro ao tocar padrão háptico: \(error.localizedDescription)")
        }
    }
}
