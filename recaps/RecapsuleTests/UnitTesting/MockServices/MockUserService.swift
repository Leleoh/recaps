//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
import CloudKit
@testable import recaps

class MockUserService: UserServiceProtocol {
    var userId: String = "teste"
    
    func loadUserId() -> String? {
        return userId
    }
    
    // MARK: - Flags para verificação
    var didCreate = false
    var didGetCurrentUser = false
    var didGetUser = false
    var didUpdateUser = false
    var didDeleteUser = false
    var didLoadUserId = false
    var didSaveUserId = false
    var didLogout = false

    // MARK: - Valores capturados
    var createdUser: User?
    var updatedUser: (user: User, name: String?, email: String?, capsules: [UUID]?)?
    var deletedUserId: String?
    var fetchedUserId: String?
    var savedUserId: String?

    // MARK: - Valores configuráveis para retorno
    var mockCurrentUser: User?
    var mockFetchedUser: User?
    var mockUserId: String = "mock-user-id"

    // MARK: - Métodos do protocolo

    func getCurrentUser() async throws -> User {
        didGetCurrentUser = true

        if let mockCurrentUser = mockCurrentUser {
            return mockCurrentUser
        }

        throw NSError(domain: "MockUserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }

    func getUser(with id: String) async throws -> User {
        didGetUser = true
        fetchedUserId = id

        if let user = mockFetchedUser {
            return user
        }

        throw NSError(domain: "MockUserService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }

    func createUser(user: User) async throws {
        didCreate = true
        createdUser = user
    }

    func updateUser(_ user: User, name: String?, email: String?, capsules: [UUID]?) async throws -> User {
        didUpdateUser = true
        updatedUser = (user, name, email, capsules)

        // Retorna uma cópia simulada do usuário atualizado
        return User(
            id: user.id,
            name: name ?? user.name,
            email: email ?? user.email,
            capsules: capsules ?? user.capsules
        )
    }

    func deleteUser() async throws {
        didDeleteUser = true
        deletedUserId = mockUserId
    }

    func loadUserId() -> String {
        didLoadUserId = true
        return mockUserId
    }

    func saveUserId(_ id: String) {
        didSaveUserId = true
        savedUserId = id
    }

    func getUserId() -> String {
        didLoadUserId = true
        return mockUserId
    }

    func logout() {
        didLogout = true
    }
}
