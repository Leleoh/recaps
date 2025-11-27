//
//  InvitePopUp.swift
//  recaps
//
//  Created by Ana Poletto on 27/11/25.
//

import SwiftUI

struct InvitePopUp: View {
    @Binding var isShowing: Bool
    let code: String

    var body: some View {
        ZStack {
            // Fundo escuro
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }
            
            popupContent
        }
    }
    
    private var popupContent: some View {
        let content = VStack(spacing: 29) {
            VStack(alignment: .leading, spacing: 34) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Recapsule is ready")
                        .font(.headline)
                    
                    Text("Copy code to invite friends.")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                }
                
                // TEXTFIELD
                HStack(spacing: 8) {
                    ForEach(Array(code), id: \.self) { char in
                        Text(String(char))
                            .font(.headline)
                            .frame(width: 48, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.darkSecondary)
                            )
                    }
                }
            }
            
            HStack(spacing: 12) {
                
                Button {
                    isShowing = false
                } label: {
                    Text("Later")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.fillsSecondary)
                        )
                        .foregroundColor(.primary)
                }
                
                Button {
                    UIPasteboard.general.string = code
                    isShowing = false
                } label: {
                    Text("Copy")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.accentColor)
                        )
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: 300)
        
        return Group {
            if #available(iOS 18.0, *) {
                content
                    .glassEffect(in: .rect(cornerRadius: 32))
            } else {
                content
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}
