//
//  UserServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import Foundation
protocol UserServiceProtocol {
    func getCurrentUser(userId: String) async throws -> User
    func createUser(user: User) async throws
}
