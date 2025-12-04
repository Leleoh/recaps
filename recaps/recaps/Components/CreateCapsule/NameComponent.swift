//
//  NameComponent.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 26/11/25.
//

import SwiftUI

struct NameComponent: View {
    
    @Binding var text: String
    @State var lineLimiter = 1
    
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
        
        TextField("Name your recapsule", text: $text, axis: .vertical)
            .environment(\.colorScheme, .light)

            .font(.coveredByYourGraceTitle)
//            .font(.system(size: 20, weight: .bold, design: .default))
            .multilineTextAlignment(.center)
            .rotationEffect(.degrees(-2))
            .foregroundStyle(.black) //Label
            .frame(maxWidth: 250, minHeight: 54)

            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .submitLabel(.done)
            .focused($isFocused)
            .onSubmit {
                isFocused = false
            }
            .background(
                Image("NameBanner")
                    .resizable()

//                    .scaledToFill()
                    .frame(maxWidth: 260)
//                    .clipped()
            )
            .onChange(of: text) { oldValue, newValue in
                if newValue.last == "\n" {
                    text = String(newValue.dropLast()) // Remove o \n
                    isFocused = false // Fecha o teclado
                }

                else if newValue.count > 38 {
                    text = oldValue
                }
            }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        NameComponent(text: .constant(""))
    }
}
