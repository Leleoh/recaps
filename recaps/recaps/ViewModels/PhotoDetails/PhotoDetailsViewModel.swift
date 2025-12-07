//
//  PhotoDetailsViewModel.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import Photos
import SwiftUI
import UIKit

@Observable
class PhotoDetailsViewModel {
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    var user: User? = nil
    var saveMessage: String?
    var userName: String = ""
    
    // 👇 imagem que vamos compartilhar
    var shareableImage: UIImage?
    
    func getUser(id: String) async -> String? {
        return try? await userService.getUser(with: id).name
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func loadShareableImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.shareableImage = image
                }
            }
        } catch {
            print("Erro ao baixar imagem para share:", error)
        }
    }
}
