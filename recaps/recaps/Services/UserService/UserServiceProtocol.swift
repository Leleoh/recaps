//
//  UserServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import Foundation
protocol UserServiceProtocol {
    func getCurrentUser() async throws -> User
    func createUser(user: User) async throws
    func loadUserId() -> String
    func saveUserId(_ id: String)
    func getUserId() -> String
    func logout()
}
