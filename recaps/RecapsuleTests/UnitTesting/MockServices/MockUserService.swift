//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
@testable import recaps

class MockUserService: UserServiceProtocol {

    // MARK: - Mocked state
    var userId: String = ""
    var shouldThrowOnGetCurrent = false
    var shouldThrowOnUpdate = false

    // flags
    var getCurrentUserCalled = false
    var createUserCalled = false
    var updateUserCalled = false

    // captured values
    var createdUser: User?
    var updatedUserInput: (user: User, name: String?, email: String?, capsules: [UUID]?)?

    // MARK: - User ID handling
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
