//
//  UserServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import Foundation
protocol UserServiceProtocol {
    var userId: String { get }
    
    func getCurrentUser() async throws -> User
    func createUser(user: User) async throws
    func updateUser(_ user: User, name: String?, email: String?, capsules: [UUID]?, openCapsules: [UUID]?) async throws -> User
    func loadUserId() -> String
    func saveUserId(_ id: String)
    func getUserId() -> String
    func logout()
}
