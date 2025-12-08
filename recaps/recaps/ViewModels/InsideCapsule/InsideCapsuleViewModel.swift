//
//  InsideCapsuleViewModel.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 24/11/25.
//

import SwiftUI
import Foundation
import PhotosUI

@Observable
class InsideCapsuleViewModel: InsideCapsuleViewModelProtocol {
    
    private var capsuleService = CapsuleService()
    private var userService = UserService()

    
    var selectedImages: [UIImage] = []
    var selectedPickerItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadSelectedImages()
            }
        }
    }
    
    var capturedImage: UIImage?
    var capturedPickerItem: PhotosPickerItem?
    
    var users: [User] = []
    
    var capsuleOwner: String = ""
    
    var currentTime: Date = Date()
    
    var gameSubmission: Submission?

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
    
    func reloadCapsule(id: UUID) async throws -> Capsule? {
        try await capsuleService.fetchCapsules(IDs: [id]).first
    }
    
    func getUsers(IDs: [String], ownerID: String) async throws {
        
        do{
            users = try await userService.getUsers(IDs: IDs)
            capsuleOwner = users.first(where: { $0.id == ownerID })?.name ?? ""
            print("Success")
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    func generateDailySubmission(capsule: Capsule) async throws {
        let possibleSubmissions = try await capsuleService.fetchPossibleSubmissions(capsule: capsule)
        
        guard let dailySubmission = possibleSubmissions.first else {
            throw CapsuleError.noAvailableSubmissions
        }
        
        try await capsuleService.addSubmissionToBlacklist(
            capsule: capsule,
            submissionId: dailySubmission.id
        )
        
        gameSubmission = dailySubmission
    }

    enum CapsuleError: Error {
        case noAvailableSubmissions
    }
    
    func setTime() async throws {
        do {
            currentTime = try await capsuleService.fetchBrazilianTime()
        } catch {
            currentTime = Date()
        }
    }
}

