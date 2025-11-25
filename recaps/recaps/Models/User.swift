//
//  User.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import Foundation
import CloudKit
// MARK: - User

struct User {
    let id: String
    var name: String
    var email: String
    var capsules: [UUID]
}

