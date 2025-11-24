//
//  CreateCapsuleViewModelProtocol.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 24/11/25.
//

import Foundation
import PhotosUI
import SwiftUI

protocol CreateCapsuleViewModelProtocol {
    var capsuleName: String { get set }
    var offensiveDuration: Int { get set }
    var selectedPickerItems: [PhotosPickerItem] { get set }
    var selectedImages: [UIImage] { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var isValidToSave: Bool { get }
    
    func loadSelectedImages() async
    func createCapsule() async -> Bool
}
