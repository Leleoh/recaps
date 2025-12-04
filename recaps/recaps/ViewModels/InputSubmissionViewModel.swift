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
class InputSubmissionViewModel{
    
    private let ckCapsuleService = CapsuleService()
    private let ckUserService = UserService()
    
    var images: [UIImage]
    var messages: [String]
    
    var capsuleID: UUID
    var authorID: String
        
    init(images: [UIImage], capsuleID: UUID) {
        self.images = images
        self._messages = Array(repeating: "", count: images.count)
        self.capsuleID = capsuleID
        self.authorID = ckUserService.getUserId()
    }
    
    func submit() async throws {
        var submissionsToCreate: [Submission] = []
        
        for (index, _) in images.enumerated() {
            let message = messages[index]
            
            let newSubmission = Submission(
                id: UUID(),
                imageURL: nil,
                description: message,
                authorId: authorID,
                date: Date(),
                capsuleID: capsuleID
            )
                        
            print("id do author: \(authorID)")
            print("🆔 ID da Submission \(index): \(newSubmission.id.uuidString)")
            
            submissionsToCreate.append(newSubmission)
        }
        
        try await ckCapsuleService.createMultipleSubmissions(
            submissions: submissionsToCreate,
            capsuleID: capsuleID,
            images: images
        )
        
    }
}

