//
//  UserServiceProtocol.swift
//  recaps
//
//  Created by Fernando Sulzbach on 05/12/25.
//
import Foundation
import UIKit

protocol InputSubmissionProtocol {
    var images: [UIImage] { get set }
    var capsuleID: UUID { get set }
    
    func submit() async throws
}
