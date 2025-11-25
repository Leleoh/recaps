//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Foundation
import CloudKit
@testable import recaps

class MockCapsuleService: CapsuleServiceProtocol {
    // MARK: - Trackers
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    
    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?
    
    func createCapsule(capsule: recaps.Capsule) async throws -> UUID {
        didCreate = true
        createdCapsule = capsule
        return capsule.id
    }
        var storedCapsules: [UUID: Capsule] = [:]
        var storedSubmissions: [UUID: [Submission]] = [:]
    
    func deleteCapsule(capsuleID: UUID) async throws {
        didDelete = true
        deletedCapsuleID = capsuleID
        storedCapsules.removeValue(forKey: capsuleID)
    }
    
    func updateCapsule(capsule: Capsule) async throws {
        didUpdate = true
        updatedCapsule = capsule
        storedCapsules[capsule.id] = capsule
    }

    // MARK: - Simulated fetching

    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission] {
        return storedSubmissions[capsuleID] ?? []
    }

    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule] {
        var result: [Capsule] = []
        for id in IDs {
            guard var capsule = storedCapsules[id] else { continue }
            capsule.submissions = try await fetchSubmissions(capsuleID: id)
            result.append(capsule)
        }
        return result
    }

    // MARK: - Helpers para testes
    func addSubmission(_ submission: Submission) {
        storedSubmissions[submission.capsuleID, default: []].append(submission)
    }
}
