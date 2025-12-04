//
//  LiquidByVer.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 27/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyLiquidGlass<S: Shape>(
        shape: S = RoundedRectangle(cornerRadius: 12),
        shadow: Bool = true
    ) -> some View {

        if #available(iOS 26, *) {
            // iOS 26+ → Liquid Glass nativo
            self
                .clipShape(shape)
                .glassEffect(.regular.interactive(), in: shape)
//                .opacity(0.8) // Caso necesário ajuste de opacidade

        } else {
            // fallback geral para iOS < 26
            self
                .background {
                    shape
                        .fill(.ultraThinMaterial)
//                      .opacity(0.8) // Caso necesário ajuste de opacidade
                }
                .clipShape(shape)
                .overlay {
                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.12),
                                    Color.black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: shadow ? 8 : 0,
                    x: 0, y: 4
                )
        }
    }
}
