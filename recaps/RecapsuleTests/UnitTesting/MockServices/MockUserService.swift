//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
@testable import recaps

final class MockUserService: UserServiceProtocol {

    // MARK: - Mocked State
    var userId: String = "mock-user-id"

    // Estado em memória
    private var storedUsers: [String: User] = [:]

    // Configurações de retorno
    var mockCurrentUser: User?
    var mockFetchedUser: User?
    var shouldThrowOnGetCurrent = false
    var shouldThrowOnUpdate = false

    // MARK: - Spy Flags
    var didCreate = false
    var didGetCurrentUser = false
    var didGetUser = false
    var didUpdateUser = false
    var didDeleteUser = false
    var didLoadUserId = false
    var didSaveUserId = false
    var didLogout = false
    var didChangeCompletedCapsuleToOpenCapsule = false
    var didGetUsers = false

    // MARK: - Captured values
    var createdUser: User?
    var deletedUserId: String?
    var fetchedUserId: String?

    // MARK: - Protocol Methods

    func getCurrentUser() async throws -> User {
        didGetCurrentUser = true

        if shouldThrowOnGetCurrent {
            throw NSError(
                domain: "MockUserService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Forced error on getCurrentUser"]
            )
        }

        if let mock = mockCurrentUser {
            return mock
        }

        if let stored = storedUsers[userId] {
            return stored
        }

        return User(
            id: userId,
            name: "Mock User",
            email: "mock@test.com",
            capsules: [],
            openCapsules: []
        )
    }

    func getUser(with id: String) async throws -> User {
        didGetUser = true
        fetchedUserId = id

        if let mock = mockFetchedUser {
            return mock
        }

        if let stored = storedUsers[id] {
            return stored
        }

        throw NSError(
            domain: "MockUserService",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Mock user not found"]
        )
    }

    func getUsers(IDs: [String]) async throws -> [User] {
        didGetUsers = true
        return IDs.compactMap { storedUsers[$0] }
    }

    func createUser(user: User) async throws {
        didCreate = true
        createdUser = user

        storedUsers[user.id] = user
        mockCurrentUser = user
        userId = user.id
    }

    func updateUser(
        _ user: User,
        name: String?,
        email: String?,
        capsules: [UUID]?,
        openCapsules: [UUID]?
    ) async throws -> User {

        didUpdateUser = true

        if shouldThrowOnUpdate {
            throw NSError(
                domain: "MockUserService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Forced error on updateUser"]
            )
        }

        let updated = User(
            id: user.id,
            name: name ?? user.name,
            email: email ?? user.email,
            capsules: capsules ?? user.capsules,
            openCapsules: openCapsules ?? user.openCapsules
        )

        storedUsers[user.id] = updated
        mockCurrentUser = updated

        return updated
    }

    func changeCompletedCapsuleToOpenCapsule(user: User, capsuleId: UUID) async throws {
        didChangeCompletedCapsuleToOpenCapsule = true

        guard var current = storedUsers[user.id] ?? mockCurrentUser else { return }

        current.capsules.removeAll { $0 == capsuleId }

        if !current.openCapsules.contains(capsuleId) {
            current.openCapsules.append(capsuleId)
        }

        storedUsers[user.id] = current
        mockCurrentUser = current
    }

    func deleteUser() async throws {
        didDeleteUser = true
        deletedUserId = userId

        storedUsers.removeValue(forKey: userId)
        mockCurrentUser = nil
        logout()
    }

    // MARK: - User ID handling

    func loadUserId() -> String? {
        didLoadUserId = true
        return userId.isEmpty ? nil : userId
    }

    func saveUserId(_ id: String) {
        didSaveUserId = true
        userId = id
    }

    func getUserId() -> String {
        return userId
    }

    func logout() {
        didLogout = true
        userId = ""
        mockCurrentUser = nil
    }

    // MARK: - Helpers

    func addUser(_ user: User) {
        storedUsers[user.id] = user
    }

    func resetTrackers() {
        didCreate = false
        didGetCurrentUser = false
        didGetUser = false
        didGetUsers = false
        didUpdateUser = false
        didDeleteUser = false
        didLoadUserId = false
        didSaveUserId = false
        didLogout = false
        didChangeCompletedCapsuleToOpenCapsule = false

        shouldThrowOnGetCurrent = false
        shouldThrowOnUpdate = false
    }
}
