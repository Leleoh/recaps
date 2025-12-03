//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
@testable import recaps

class MockUserService: UserServiceProtocol {

    var userId: String = "teste"
    
    func loadUserId() -> String? {
        return userId
    }
    
    // MARK: - Mocked state
    var userId: String = ""
    var shouldThrowOnGetCurrent = false
    var didGetUser = false
    var didUpdateUser = false
    var didDeleteUser = false
    var shouldThrowOnUpdate = false

    // flags
    var getCurrentUserCalled = false
    var createUserCalled = false
    var updateUserCalled = false

    // captured values
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
        userId = id
    }

    func loadUserId() -> String { userId }
    func getUserId() -> String { userId }
    func logout() {}

    // MARK: - User ops
    func getCurrentUser() async throws -> User {
        getCurrentUserCalled = true

        if shouldThrowOnGetCurrent {
            throw NSError(domain: "mock", code: 1)
        }

        return User(id: userId, name: "Mock name", email: "mock@mock.com", capsules: [])
    }

    func createUser(user: User) async throws {
        createUserCalled = true
        createdUser = user
    }

    // MARK: - UPDATE
    func updateUser(
        _ user: User,
        name: String?,
        email: String?,
        capsules: [UUID]?
    ) async throws -> User {

        updateUserCalled = true
        updatedUserInput = (user, name, email, capsules)

        if shouldThrowOnUpdate {
            throw NSError(domain: "mockUpdate", code: 2)
        }

        // Simula o retorno de um user atualizado
        return User(
            id: user.id,
            name: name ?? user.name,
            email: email ?? user.email,
            capsules: capsules ?? user.capsules
        )
    }
}
