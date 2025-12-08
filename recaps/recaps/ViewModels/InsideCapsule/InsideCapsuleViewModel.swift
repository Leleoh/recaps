//
//  InputViewModel 2.swift
//  recaps
//
//  Created by Fernando Sulzbach on 02/12/25.
//


//
//  InputViewModel.swift
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
    
    func setTime() async throws {
        do {
            currentTime = try await capsuleService.fetchBrazilianTime()
        } catch {
            currentTime = Date()
        }
    }
}

