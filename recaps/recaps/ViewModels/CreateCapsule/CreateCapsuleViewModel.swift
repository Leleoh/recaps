//
//  CreateCapsuleViewModel.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 24/11/25.
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
class CreateCapsuleViewModel: CreateCapsuleViewModelProtocol {
    
    // MARK: - Properties
    var capsuleName: String = ""
    var offensiveDuration: Int = 1
    
    // Controle do PhotosUI
    var selectedPickerItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadSelectedImages()
            }
        }
    }
    var selectedImages: [UIImage] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Regra de validação: Nome preenchido E pelo menos 3 fotos
    var isValidToSave: Bool {
        return !capsuleName.isEmpty && selectedImages.count >= 3
    }
    
    private let cloudKitService: CKServiceProtocol
    
    init(service: CKServiceProtocol = CloudKitService()) {
        self.cloudKitService = service
    }
    
    // MARK: - Image Loading Logic
    func loadSelectedImages() async {
        var loadedImages: [UIImage] = []
        
        for item in selectedPickerItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loadedImages.append(image)
            }
        }
        
        await MainActor.run {
            self.selectedImages = loadedImages
        }
    }
    
    // MARK: - CloudKit Operations
    func createCapsule() async -> Bool {
        guard isValidToSave else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let newCapsuleID = UUID()
        let currentUserID = UUID() // TODO: Substituir pelo ID real do User quando tiver autenticação
        
        // Criar o Objeto Cápsula
        let newCapsule = Capsule(
            id: newCapsuleID,
            code: String(UUID().uuidString.prefix(5)), // Lógica provisória de código, precisa ser ajustado para a geração de um código aleatório que será repassado para outras pessoas se juntarem àquela capsula
            submissions: [], // Começa vazia, as submissions são linkadas pelo ID (Aqui não deveria já conter uma submission referente às 3 imagens inseridas na criação da capsula?)
            name: capsuleName,
            createdAt: Date(),
            offensive: offensiveDuration,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [currentUserID],
            ownerId: currentUserID,
            status: .inProgress
        )
        
        do {
            // Salvar a Cápsula
            try await cloudKitService.createCapsule(capsule: newCapsule)
            print("Cápsula criada com sucesso: \(newCapsule.name)")
            
            // Salvar as Imagens (Submissions)
            // Iteramos sobre as imagens carregadas e criamos uma submission para cada
            for image in selectedImages {
                let newSubmission = Submission(
                    id: UUID(),
                    imageURL: nil, // CloudKit gerencia a URL do asset
                    description: nil, // Descrição opcional
                    authorId: currentUserID,
                    date: Date(),
                    capsuleID: newCapsuleID // Linkando com a cápsula criada
                )
                
                try await (cloudKitService as? CloudKitService)?.createSubmission(
                    submission: newSubmission,
                    capsuleID: newCapsuleID,
                    image: image
                )
            }
            
            isLoading = false
            return true
            
        } catch {
            print("Erro no fluxo de criação: \(error)")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Erro ao criar cápsula: \(error.localizedDescription)"
            }
            return false
        }
    }
}
