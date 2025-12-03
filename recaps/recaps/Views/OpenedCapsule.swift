//
//  OpenedCapsule.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 02/12/25.
//

import SwiftUI

struct OpenedCapsule: View {
    
    let capsule: Capsule
    
    @State private var viewModel = OpenedCapsuleViewModel()
    
    var body: some View {
        ScrollView{
            
            VStack{
                
                Text("\(capsule.name)")
                    .font(.largeTitle)
                
                Divider()
                
                if viewModel.isLoading {
                    ProgressView("Carregando memórias")
                        .padding()
                }else if let error = viewModel.errorMessage{
                    Text(error)
                }
                else if viewModel.submissions.isEmpty{
//                    print("Não existem memórias nessa cápsula")
                    ContentUnavailableView("Nenhuma memória", systemImage: "photo.on.rectangle", description: Text("Essa cápsula ainda está vazia."))
                }
                else{
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10 ){
                        ForEach(viewModel.submissions){ submission in
                            
                            if let url = submission.imageURL,
                               let data = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: data){
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                            }else{
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(Image(systemName: "photo"))
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
        }
        .task {
            await viewModel.fetchSubmissions(for: capsule.id)
        }
    }
        
}

#Preview {
    let mockCapsule = Capsule(
        id: UUID(),
        code: "TESTE1",
        submissions: [], // Lista vazia de submissions
        name: "Cápsula de Teste",
        createdAt: Date(),
        offensive: 10,
        offensiveTarget: 50,
        lastSubmissionDate: Date(),
        validOffensive: true,
        lives: 3,
        members: [],
        ownerId: "user123",
        status: .completed // Teste com status completado
    )
    return OpenedCapsule(capsule: mockCapsule)
}
