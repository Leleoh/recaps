//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//
import Foundation
@testable import recaps

class MockCKService: CKServiceProtocol {
    var didCreate = false
    var didDelete = false
    var didUpdate = false

    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?

    func createCapsule(capsule: Capsule) async throws {
        didCreate = true
        createdCapsule = capsule
    }

    func deleteCapsule(capsuleID: UUID) async throws {
        didDelete = true
        deletedCapsuleID = capsuleID
    }

    func updateCapsule(capsule: Capsule) async throws {
        didUpdate = true
        updatedCapsule = capsule
    }
}
