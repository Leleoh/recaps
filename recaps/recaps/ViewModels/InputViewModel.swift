//
//  InputViewModel.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 24/11/25.
//

import SwiftUI
import Foundation
import Observation


@Observable
class InputViewModel{
    var caption: String = ""
    var selectedImage: UIImage?
    var isUploading: Bool = false
    var errorMessage: String? = nil
    var shouldDismiss: Bool = false
    
    private let ckService = CloudKitService()
    
    @MainActor
    func saveMemory(capsuleID: UUID) async {
        guard let image = selectedImage else{
            return
        }
        isUploading = true
        errorMessage = nil
        
        //Criando uma submission
        let newSubmission = Submission(
            id: UUID(),
            imageURL: nil,
            description: caption,
            authorId: UUID(),
            date: Date(),
            capsuleID: capsuleID
        )
        
        do{
            try await ckService.createSubmission(submission: newSubmission, capsuleID: capsuleID, image: image)
            
            isUploading = false
            shouldDismiss = true
        }catch{
            // Erro
            isUploading = false
            errorMessage = "Ocorreu um erro ao salvar a memória. \(error.localizedDescription)"
        }
        
    
    }
    
}

