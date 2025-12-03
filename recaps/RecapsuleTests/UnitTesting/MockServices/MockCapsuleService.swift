//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Foundation
import CloudKit
@testable import recaps
import UIKit

class MockCapsuleService: CapsuleServiceProtocol {
    
    
    // MARK: - Trackers
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    var mockSubmissionsToReturn: [Submission] = []
    var shouldReturnError: Bool = false
    
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
        if shouldReturnError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Erro simulado"])
        }
        return mockSubmissionsToReturn
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
    
    //Testar essas 3 abaixo posteriormente
    func createSubmission(submission: recaps.Submission, capsuleID: UUID, image: UIImage) async throws {
        
    }
    
    func fetchAllCapsules() async throws -> [recaps.Capsule] {
        var result: [Capsule] = []
        for (id, var capsule) in storedCapsules {
            capsule.submissions = try await fetchSubmissions(capsuleID: id)
            result.append(capsule)
        }
        return result
    }
    
    func fetchAllCapsulesWithoutSubmissions() async throws -> [recaps.Capsule] {
        return Array(storedCapsules.values)
    }
}
