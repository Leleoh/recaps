//
//  Submission.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import Foundation

// MARK: - Submission
struct Submission: Codable, Identifiable {
    let id: UUID
    let imageURL: URL?
    let description: String?
    let authorId: UUID
    let date: Date
    let capsuleID: UUID
}

