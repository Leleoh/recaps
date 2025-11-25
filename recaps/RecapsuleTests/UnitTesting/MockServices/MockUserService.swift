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
    var didCreate = false
    var didGetCurrentUser = false
    
    var createdUser: User?
    var fetchedUserId: String?
    
    func getCurrentUser(userId: String) async throws -> recaps.User {
        didGetCurrentUser = true
        fetchedUserId = userId
        return User(
            id: userId,
            name: "Mock User",
            email: "mock@example.com",
            capsules: []
        )
    }
    
    func createUser(user: recaps.User) async throws {
        didCreate = true
        createdUser = user
    }
}

