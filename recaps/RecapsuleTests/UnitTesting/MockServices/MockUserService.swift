//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
@testable import recaps

class MockUserService: UserServiceProtocol {
    
    // MARK: - Mocked state / configurable returns
    var userId: String = "mock-user-id"
    var mockCurrentUser: User?
    var mockFetchedUser: User?
    
    var shouldThrowOnGetCurrent = false
    var shouldThrowOnUpdate = false

    // MARK: - Flags (Spy Pattern)
    var didCreate = false
    var didGetCurrentUser = false
    var didGetUser = false
    var didUpdateUser = false
    var didDeleteUser = false
    var didLoadUserId = false
    var didSaveUserId = false
    var didLogout = false

    // MARK: - Captured values (para asserts nos testes)
    var createdUser: User?
    // Unificação: mantendo o nome 'updatedUser' para consistência, substitui 'updatedUserInput' da dev
    var updatedUser: (user: User, name: String?, email: String?, capsules: [UUID]?)?
    var deletedUserId: String?
    var fetchedUserId: String?
    var savedUserId: String?

    // MARK: - User ops
    
    func getCurrentUser() async throws -> User {
        didGetCurrentUser = true

        if shouldThrowOnGetCurrent {
            // Unificação de erro: Usando userInfo detalhado da TK25
            throw NSError(domain: "MockUserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Forced error on getCurrentUser"])
        }

        if let user = mockCurrentUser {
            return user
        }

        return User(id: userId, name: "Mock name", email: "mock@mock.com", capsules: [])
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

        if shouldThrowOnUpdate {
            throw NSError(domain: "MockUserService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Forced error on updateUser"])
        }

        // Retorna o objeto atualizado simulado
        return User(
            id: user.id,
            name: name ?? user.name,
            email: email ?? user.email,
            capsules: capsules ?? user.capsules
        )
    }

    func deleteUser() async throws {
        didDeleteUser = true
        deletedUserId = userId
    }

    // MARK: - User ID handling

    // Mantendo assinaturas da TK25 que parecem refletir uma atualização no protocolo
    func loadUserId() -> String? {
        didLoadUserId = true
        return userId
    }

    func saveUserId(_ id: String) {
        didSaveUserId = true
        savedUserId = id
        userId = id
    }

    func getUserId() -> String {
        didLoadUserId = true // Nota: getUserId e loadUserId as vezes se confundem, mas mantive ambos para compatibilidade
        return userId
    }

    func logout() {
        didLogout = true
    }
}
