//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Foundation
import UIKit
@testable import recaps

class MockCapsuleService: CapsuleServiceProtocol {

    // MARK: - Trackers
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    var didFetchCapsules = false
    var didCreateSubmission = false
    var didCheckValidOffensive = false

    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?
    var fetchedCapsuleIDs: [UUID] = []
    var createdSubmission: Submission?

    // MARK: - Internal storage
    var storedCapsules: [UUID: Capsule] = [:]
    var storedSubmissions: [UUID: [Submission]] = [:]

    // MARK: - Capsules
    func createCapsule(capsule: Capsule) async throws -> UUID {
        didCreate = true
        createdCapsule = capsule
        storedCapsules[capsule.id] = capsule
        return capsule.id
    }

    func updateCapsule(capsule: Capsule) async throws {
        didUpdate = true
        updatedCapsule = capsule
        storedCapsules[capsule.id] = capsule
    }

    func deleteCapsule(capsuleID: UUID) async throws {
        didDelete = true
        deletedCapsuleID = capsuleID
        storedCapsules.removeValue(forKey: capsuleID)
        storedSubmissions.removeValue(forKey: capsuleID)
    }

    // MARK: - Submissions
    func createSubmission(submission: Submission, capsuleID: UUID, image: UIImage) async throws {
        didCreateSubmission = true
        createdSubmission = submission

        storedSubmissions[capsuleID, default: []].append(submission)

        if var capsule = storedCapsules[capsuleID] {
            capsule.submissions.append(submission)
            capsule.lastSubmissionDate = submission.date
            storedCapsules[capsuleID] = capsule
        }
    }

    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission] {
        return storedSubmissions[capsuleID] ?? []
    }

    // MARK: - Fetching Capsules
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule] {
        didFetchCapsules = true
        fetchedCapsuleIDs = IDs
        return IDs.compactMap { storedCapsules[$0] }
    }

    func fetchAllCapsules() async throws -> [Capsule] {
        didFetchCapsules = true
        return Array(storedCapsules.values)
    }

    func fetchAllCapsulesWithoutSubmissions() async throws -> [Capsule] {
        didFetchCapsules = true
        return storedCapsules.values.map { capsule in
            var copy = capsule
            copy.submissions = []
            return copy
        }
    }

    // MARK: - Capsule Logic (Mocked)
    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool {
        didCheckValidOffensive = true

        guard let capsule = storedCapsules[capsuleID] else {
            return false
        }

        let last = capsule.lastSubmissionDate
        let diff = Date().timeIntervalSince(last)
        let limit: TimeInterval = 48 * 60 * 60

        return diff < limit
    }

    func checkIfCapsuleIsCompleted(capsuleID: UUID) async throws -> Bool {
        guard let capsule = storedCapsules[capsuleID] else { return false }
        return capsule.status == .completed
    }

    func checkIfIncreasesStreak(capsuleID: UUID) async throws {
        // Mock vazio - não faz nada
    }

    // MARK: - Extra helper for tests
    func createCapsuleWithSubmissions(
        capsule: Capsule,
        submissions: [Submission],
        images: [UIImage]
    ) async throws -> UUID {

        storedCapsules[capsule.id] = capsule
        storedSubmissions[capsule.id] = submissions

        var updated = capsule
        updated.submissions = submissions
        storedCapsules[capsule.id] = updated

        return capsule.id
    }

    func resetTrackers() {
        didCreate = false
        didDelete = false
        didUpdate = false
        didFetchCapsules = false
        didCreateSubmission = false
        didCheckValidOffensive = false

        createdCapsule = nil
        updatedCapsule = nil
        deletedCapsuleID = nil
        fetchedCapsuleIDs = []
        createdSubmission = nil
    }
}
