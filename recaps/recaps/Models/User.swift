//
//  User.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var capsulesIDs: [UUID]
}


