//
//  InvitePopUp.swift
//  recaps
//
//  Created by Ana Poletto on 26/11/25.
//

import SwiftUI

struct InvitePopUp: View {
    @Binding var isShowing: Bool
    let join: (String) -> Void

    @State private var code: String = ""
    private let numberOfCells: Int = 5

    var body: some View {
        ZStack {
            // Fundo escuro
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }

            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Join Recapsule")
                        .font(.headline)

                    Text("Insert invite code to join.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // TEXT FIELD ESTILIZADO
                TextField("Code", text: $code)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.secondary.opacity(0.15))
                    )

                HStack(spacing: 12) {

                    // CANCEL
                    Button {
                        isShowing = false
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundColor(.primary)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.secondary.opacity(0.2))
                            )
                    }

                    // JOIN
                    Button {
                        join(code)
                    } label: {
                        Text("Join")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundColor(.primary)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        code.count < numberOfCells
                                        ? Color.secondary.opacity(0.3)
                                        : Color.accentColor
                                    )
                            )
                    }
                    .disabled(code.count < numberOfCells)
                }

                Text("We couldn't find this Recapsule, check the code and try again.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial) 
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
