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
        cornerRadius: CGFloat? = nil,
        shadow: Bool = true
    ) -> some View {
        if #available(iOS 26, *) {
            // usa API nativa do iOS 26 (requer iOS 26 SDK no Xcode)
            self
                .clipShape(shape)
                .glassEffect(.regular.interactive(), in: shape)
        } else if #available(iOS 15, *) {
            // fallback moderno: Material
            self
                .background {
                    shape
                        .fill(.ultraThinMaterial)
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
                .shadow(color: Color.black.opacity(0.2), radius: shadow ? 8 : 0, x: 0, y: 4)
        } else {
            // fallback legacy
            self
                .background {
                    shape
                        .fill(Color.white.opacity(0.72))
                }
                .clipShape(shape)
                .overlay {
                    shape
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.2), radius: shadow ? 6 : 0, x: 0, y: 3)
        }
    }
}

