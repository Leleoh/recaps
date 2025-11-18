//
//  User.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var mail: String
    var capsulesIDs: [UUID]
    var photo: Data
}


