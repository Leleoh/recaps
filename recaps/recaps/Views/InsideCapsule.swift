//
//  InsideCapsule.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 24/11/25.
//

import SwiftUI

struct InsideCapsule: View {
    var body: some View {
        
        VStack{
            Text("Nome da capsula")
                .padding(.top, 24)
            
            Spacer()
            
            ZStack{
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .frame(width: 350, height: 600)
                
                Text("Informações da capsula")
                    .foregroundStyle(.white)
                
                
            }
            
            Spacer()
                
        }
    }
}

#Preview {
    InsideCapsule()
}
