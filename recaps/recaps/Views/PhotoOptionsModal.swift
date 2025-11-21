//
//  InsertDataView.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 21/11/25.
//

import SwiftUI

struct PhotoOptionsModal: View {
    var onTakePhoto: () -> Void
    var onChoosePhoto: () -> Void
    
    @State private var caption: String = ""

    var body: some View {
        VStack {
            Button("Take Photo") {
                onTakePhoto()
            }
            Button("Choose Photo") {
                onChoosePhoto()
            }
            .padding(.top, 60)
            
            Spacer()
            
            TextField("Digite uma legenda", text: $caption)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .contentShape(Rectangle())
        
        
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .padding(.top, 40)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PhotoOptionsModal(onTakePhoto: {}, onChoosePhoto: {})
}
