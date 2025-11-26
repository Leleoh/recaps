//
//  NameComponent.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 26/11/25.
//

import SwiftUI

struct NameComponent: View {
    
    @State private var text: String = ""
    @State var lineLimiter = 1
    
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
    
        TextField("Name your recapsule", text: $text, axis: .vertical)
            .font(.system(size: 18))
            .multilineTextAlignment(.center)
            .rotationEffect(.degrees(-2))
            .foregroundStyle(.secondary) //Label
            .frame(maxWidth: 250)
            .lineLimit(2)
            .padding(.horizontal, 8)
            .background(Color.clear)
            .submitLabel(.done)
            .focused($isFocused)
            .onSubmit {
                isFocused = false
            }
            .background(
                Image("NameBanner")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 260)
            )
        .onChange(of: text) { oldValue, newValue in
            if newValue.last == "\n" {
                text = String(newValue.dropLast()) // Remove o \n
                isFocused = false // Fecha o teclado
            }
            else if newValue.count > 50 {
                text = oldValue
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        NameComponent()
    }
}
