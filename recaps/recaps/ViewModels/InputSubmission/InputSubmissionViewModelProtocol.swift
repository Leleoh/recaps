//
//  InputSubmissionViewModelProtocol.swift
//  recaps
//
//  Created by Fernando Sulzbach on 05/12/25.
//
import Foundation
import UIKit

protocol InputSubmissionViewModelProtocol {
    var images: [UIImage] { get set }
    var messages: [String] { get set }
    var capsuleID: UUID { get set }
    var authorID: String { get set }
    
    func submit() async throws
}
