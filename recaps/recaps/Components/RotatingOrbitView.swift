//  Untitled.swift
//  Shelfie
//
//  Created by Julia Nascimento on 09/12/25.
//


import SwiftUI

struct RotatingOrbitView: View {
    @State private var rotation: Double = 0
    @State private var appear = false
    @State private var pulse: [Double] = Array(repeating: 1.0, count: 8)

    
    private let orbitRadiusX: CGFloat = 120
    private let orbitRadiusY: CGFloat = 30
    private let smallSize: CGFloat = 85
    private let centerSize: CGFloat = 250
    private let rotationDuration: Double = 14

    private let orbitImages = [
        "pin1", "pin2", "pin3",
        "pin4", "pin5"
    ]

    private let centralImageName = "BolaPrincipal"

    var body: some View {
        ZStack {

            ForEach(orbitImages.indices, id: \.self) { index in
                let baseAngle = Double(index) / Double(orbitImages.count) * 360
                let totalAngle = baseAngle + rotation

                Group {
                    Image(orbitImages[index])
                        .resizable()
                        .scaledToFill()
//                        .frame(width: smallSize, height: smallSize)
                        .frame(width: 25, height: 25)
                        .clipped()
//                        .clipShape(Circle())
                        .shadow(radius: 6)
                        .rotationEffect(.degrees(-totalAngle))
                        .scaleEffect(pulse[index])
                }
               
                .offset(x: orbitRadiusX , y: orbitRadiusY)
                .rotationEffect(.degrees(totalAngle))
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.6)
                .animation(.easeOut(duration: 0.45).delay(Double(index) * 0.04), value: appear)
            }

//            Image(centralImageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: centerSize, height: centerSize)
//                
//                .clipped()
//                .clipShape(Circle())
//                .shadow(radius: 10)
//                .zIndex(2)
                
        }
        .frame(width: (orbitRadiusX + centerSize / 2) * 2,
               height: (orbitRadiusY + centerSize / 2) * 2)

        .onAppear {
            appear = true
            
            // animação da órbita
            withAnimation(.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // animação do pulso em cada bolinha
            for i in pulse.indices {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(Double(i) * 0.25)) {
                    pulse[i] = 1.18
                }
            }
        }
    }
}

#Preview {
    
    RotatingOrbitView ()
}
