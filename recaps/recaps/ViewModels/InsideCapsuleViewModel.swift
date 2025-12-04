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
//import Observation
import PhotosUI


//@Observable
class InsideCapsuleViewModel {
    
    @State private var capsuleService = CapsuleService()
    @State private var userService = UserService()
    
    var selectedImages: [UIImage] = []
    var selectedPickerItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadSelectedImages()
            }
        }
    }

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
    
    func getUsers(IDs: [String]) async throws -> [User] {
        var users: [User] = []
        
        do{
            users = try await userService.getUsers(IDs: IDs)
            print("Success")
            
        } catch {
            print("Error: \(error)")
        }
        
        return users
    }
}

