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
            

            VStack(spacing: 29) {
                
                VStack(alignment: .leading, spacing: 34) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Recapsule is ready")
                            .font(.headline)
                        
                        Text("Copy code to invite friends.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.labelPrimary)
                    }
                    
                    // CODE CELLS
                    HStack(spacing: 8) {
                        ForEach(Array(code), id: \.self) { char in
                            Text(String(char))
                                .font(.headline)
                                .frame(width: 48, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.fillDarkSecondary)
                                )
                        }
                    }
                }
                
                // ACTION BUTTONS
                HStack(spacing: 12) {
                    
                    Button {
                        isShowing = false
                    } label: {
                        Text("Later")
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.fillsSecondary.opacity(0.35))
                            )
                            .foregroundColor(.labelPrimary)
                    }
                    
                    Button {
                        UIPasteboard.general.string = code
                        isShowing = false
                    } label: {
                        Text("Copy")
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.sweetNSour)
                            )
                            .foregroundColor(.labelPrimary)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 300)
            .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 32))
        }
    }
}
