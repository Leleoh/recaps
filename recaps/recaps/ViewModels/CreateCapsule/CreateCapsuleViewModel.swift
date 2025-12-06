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
    var offensiveTarget: Int = 30
    var showPopup = false
    var code: String = ""
    
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
    
    // MARK: - Services
    private let capsuleService: CapsuleServiceProtocol
    private let userService: UserServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService()) {
        self.capsuleService = capsuleService
        self.userService = userService
    }
    
    // MARK: Helpers
    func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"
        return String((0..<5).map { _ in chars.randomElement()! })
    }
    
    // MARK: - Image Loading
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
    
    // MARK: - Main Actor
    func createCapsule(code: String) async -> Bool {
        guard isValidToSave else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let newCapsuleID = UUID()
        let currentUserID = userService.getUserId()
        
        guard !currentUserID.isEmpty else {
            print("ERRO CRÍTICO: Tentativa de criar cápsula sem usuário logado.")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Erro: Usuário não identificado. Faça login novamente."
            }
            return false
        }
        
        // Criar o Objeto Cápsula
        let newCapsule = Capsule(
            id: newCapsuleID,
            code: code,
            submissions: [],
            name: capsuleName,
            createdAt: Date(),
            offensive: 0,
            offensiveTarget: offensiveTarget,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [currentUserID],
            ownerId: currentUserID,
            status: .inProgress,
            blacklisted: []
        )
        
        do {
            
            // Salvar a Cápsula
            
            
            
           // _ = try await capsuleService.createCapsule(capsule: newCapsule)
            //print("Cápsula criada com ID: \(newCapsule.id)")
            
            var submissionsArray: [Submission] = []
            
            // Salvar as Imagens - Iteramos sobre as imagens carregadas e criamos uma submission para cada
            for image in selectedImages {
                let newSubmission = Submission(
                    id: UUID(),
                    imageURL: nil, // CloudKit gerencia a URL do asset
                    description: nil, // Descrição opcional
                    authorId: currentUserID,
                    date: Date(),
                    capsuleID: newCapsuleID // Linkando com a cápsula criada
                )
                
                submissionsArray.append(newSubmission)
                
               // print("Enviando foto: \(image)...")
                
//                try await capsuleService.createSubmission(
//                    submission: newSubmission,
//                    capsuleID: newCapsuleID,
//                    image: image
//                )
                
              //  print("Foto \(image) salva com sucesso!")
            }
            print("Iniciando upload da cápsula: \(newCapsule.name)")
            
            try await capsuleService.createCapsuleWithSubmissions(capsule: newCapsule, submissions: submissionsArray, images: selectedImages)
            
            print("Fluxo finalizado com Sucesso!")
            
            var currentUser = try await userService.getCurrentUser()
            currentUser.capsules.append(newCapsuleID)
            
            _ = try await userService.updateUser(
                currentUser,
                name: currentUser.name,
                email: currentUser.email,
                capsules: currentUser.capsules,
                openCapsules: currentUser.openCapsules
            )
            print("✅ Usuário atualizado com a nova cápsula.")
            
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
