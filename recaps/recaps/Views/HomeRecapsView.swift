//
//  HomeRecaps.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import SwiftUI

struct HomeRecapsView: View {
    var viewModel = HomeRecapsViewModel()
    
    // Capsulas em progresso mockadas para avaliar visual.  Excluir quando não mais necessário
    private let inProgressRecaps: [Capsule] = [
        .init(id: UUID(), code: "F5GX3", submissions: [], name: "Academy", createdAt: Date(), offensive: 50, lastSubmissionDate: Date(), validOffensive: false, lives: 3, members: [], ownerId: "11111", status: CapsuleStatus.inProgress),
        .init(id: UUID(), code: "F5GX3", submissions: [], name: "Teste1", createdAt: Date(), offensive: 20, lastSubmissionDate: Date(), validOffensive: false, lives: 3, members: [], ownerId: "222", status: CapsuleStatus.inProgress),
        .init(id: UUID(), code: "F5GX3", submissions: [], name: "Teste2", createdAt: Date(), offensive: 80, lastSubmissionDate: Date(), validOffensive: false, lives: 3, members: [], ownerId: "3333", status: CapsuleStatus.inProgress),
        .init(id: UUID(), code: "F5GX3", submissions: [], name: "Teste3", createdAt: Date(), offensive: 99, lastSubmissionDate: Date(), validOffensive: false, lives: 3, members: [], ownerId: "44444", status: CapsuleStatus.inProgress)
    ]
    
    // Capsulas abertas mockadas para avaliar visual. Excluir quando não mais necessário
    private let completedRecaps: [Capsule] = [
        .init(id: UUID(), code: "SAKJ2", submissions: [], name: "Teste1", createdAt: Date(), offensive: 100, lastSubmissionDate: Date(), validOffensive: true, lives: 3, members: [], ownerId: "55555", status: CapsuleStatus.completed),
        .init(id: UUID(), code: "SAKJ2", submissions: [], name: "Teste2", createdAt: Date(), offensive: 100, lastSubmissionDate: Date(), validOffensive: true, lives: 3, members: [], ownerId: "66666", status: CapsuleStatus.completed),
        .init(id: UUID(), code: "SAKJ2", submissions: [], name: "Teste3", createdAt: Date(), offensive: 100, lastSubmissionDate: Date(), validOffensive: true, lives: 3, members: [], ownerId: "77777", status: CapsuleStatus.completed)
    ]
    
    var body: some View {
        VStack (spacing: 40) {
            VStack(alignment: .leading, spacing: 16) {
                
                // Cabeçalho da página
                HStack(alignment: .center) {
                    
                    Text("Minhas recaps")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                    
                    // Botão de perfil.
                    Button {
                        // Chamar view aqui
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 12) {
                    Button{
                        Task {
                            //Aquie cria codigo e cápsula
                            let code = viewModel.generateCode()
                            try? await viewModel.creatingCapsule(code: code, name: "Teste", offensive: 10)
                        }
                    } label: {
                        Text("Novo recap")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor.opacity(0.15))
                            )
                    }
                    
                    Button {
                        //Aqui tem que ter campo que pede código com pop up ou modela e esse que vai ser o code mandado para a função
                        Task {
                            try await viewModel.joinCapsule(code: "i1JzDF2D")
                        }
                    } label: {
                        Text("Juntar-se")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentColor, lineWidth: 1.5)
                            )
                    }
                }
            }
            
            
            .padding([.top, .horizontal], 16)
            
            
            // Capsulas em andamento.
            VStack(alignment: .leading, spacing: 24) {
                Text("Em Andamento")
                
                TabView {
                    ForEach(inProgressRecaps) { recap in
                        // Trocar pelo card correto atualizado quando o design de alta fidelidade estiver implementado ou atualizar este
                        NavigationLink{
                            InsideCapsule(capsule: recap)
                        }label:{
                            CapsuleCardComponent(capsule: recap)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
            .frame(maxHeight: 296)
            .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Concluídas")
                
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(completedRecaps) { recap in
                            CapsuleCardComponent(capsule: recap)
                                .frame(maxWidth: 169, maxHeight: 131)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeRecapsView()
}
