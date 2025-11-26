//
//  InsideCapsule.swift
//  recaps
//

//  Created by Leonel Ferraz Hernandez on 24/11/25.



import SwiftUI

struct InsideCapsule: View {
    
    var capsule: Capsule
    @State private var showInputModal = false
    
    var body: some View {
        
        VStack{
            Text(capsule.name)
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

        Spacer()
        
        Button{
            showInputModal = true
        }label:{
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.blue)
        }
        .sheet(isPresented: $showInputModal) {
            InputModal(capsuleID: capsule.id)
        }
    }
    
        
}

#Preview {

    InsideCapsule(capsule: Capsule(
        id: UUID(),
        code: "PREVIEW",
        submissions: [],
        name: "Cápsula de Teste",
        createdAt: Date(),
        offensive: 10,
        lastSubmissionDate: Date(),
        validOffensive: true,
        lives: 3,
        members: [],
        ownerId: "",
        status: .inProgress
    ))
}
