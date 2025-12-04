//
//  Submission.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import Foundation

// MARK: - Submission
struct Submission: Codable, Identifiable, Hashable {
    let id: UUID
    let imageURL: URL?
    let description: String?
    let authorId: String
    let date: Date
    let capsuleID: UUID
}

