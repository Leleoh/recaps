//
//  PhotoDetailsViewModelProtocol.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import Foundation
import UIKit

protocol PhotoDetailsViewModelProtocol {
    var user: User? { get }
    var saveMessage: String? { get }
    var userName: String { get }
    var shareableImage: UIImage? { get }
    
    func getUser(id: String) async -> String?
    func formatDate(_ date: Date) -> String
    func loadShareableImage(from url: URL) async
}
