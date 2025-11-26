//
//  CapsuleCard.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 21/11/25.
//

import SwiftUI

// MARK: Componente de design da capsula. Necessita ser atualizado para versão de high fidelity.

struct CapsuleCardComponent: View {
    
    var capsule: Capsule
    
    var body: some View {
        VStack(spacing: 12) {
            // Desenho da caixa
            ZStack {
                VStack(spacing: 10) {
                    // Título dentro do papel rasgado
                    Text(capsule.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [6,4]))
                        )
                        .foregroundStyle(.black)
                    
                    // Metadata
                    Text("Created: \(capsule.createdAt.ddMMyyyy)")
                    
                    // Barra de progresso
                    VStack(alignment: .leading) {
                        ProgressView(value: Double(capsule.offensive), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue.opacity(0.6)))
                            .frame(height: 14)
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 2)
                                    .background(Color.white.cornerRadius(0))
                                    .frame(height: 11)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 0)
                            )
                        
                        Text("\(capsule.offensive)% Complete")
                            .font(.caption)
                            .foregroundStyle(.black)
                    }
                }
                .frame(maxWidth: 240, maxHeight: 209)
            }
            .frame(maxWidth: 262, maxHeight: 209)
            .background(Color.white)
            .overlay(Rectangle()
                .stroke(Color.black, lineWidth: 2)
            )
        }
        .padding()
    }
}

#Preview {
    CapsuleCardComponent(capsule: .init(id: UUID(), code: "F5GX3", submissions: [], name: "Academy", createdAt: Date(), offensive: 0, offensiveTarget: 50, lastSubmissionDate: Date(), validOffensive: false, lives: 3, members: [], ownerId: " ", status: CapsuleStatus.inProgress))
}
