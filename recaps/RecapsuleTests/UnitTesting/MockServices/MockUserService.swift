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
    // MARK: - Flags para verificação
    var didCreate = false
    var didGetCurrentUser = false
    var didLoadUserId = false
    var didSaveUserId = false
    var didLogout = false

    // MARK: - Valores capturados
    var createdUser: User?
    var fetchedUserId: String?
    var savedUserId: String?

    // MARK: - Valores configuráveis para retorno
    var mockCurrentUser: User?
    var mockUserId: String = "mock-user-id"

    // MARK: - Métodos do protocolo

    func getCurrentUser() async throws -> User {
        didGetCurrentUser = true

        if let mockCurrentUser = mockCurrentUser {
            return mockCurrentUser
        }

        throw NSError(domain: "MockUserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
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

    func createUser(user: User) async throws {
        didCreate = true
        createdUser = user
    }
}

