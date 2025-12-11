//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Foundation
import UIKit
@testable import recaps

final class MockCapsuleService: CapsuleServiceProtocol {

    // MARK: - Trackers
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    var didFetchCapsules = false
    var didCreateSubmission = false
    var didCheckValidOffensive = false
    var didCreateCapsuleWithSubmissions = false
    var didCheckIfCapsuleIsCompleted = false
    var didCheckIfIncreasesStreak = false
    var didCreateMultipleSubmissions = false
    var createdSubmissions: [Submission]?

    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?
    var fetchedCapsuleIDs: [UUID] = []
    var createdSubmission: Submission?

    // MARK: - Estado em memória
    var storedCapsules: [UUID: Capsule] = [:]
    private var storedSubmissions: [UUID: [Submission]] = [:]

    // MARK: - Create / Update / Delete

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

    // MARK: - Fetching

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
        return storedCapsules.values.map {
            var copy = $0
            copy.submissions = []
            return copy
        }
    }

    func fetchSubmissions(capsuleID: UUID, limit: Int? = nil) async throws -> [Submission] {
        let all = storedSubmissions[capsuleID] ?? []
        if let limit { return Array(all.prefix(limit)) }
        return all
    }

    func fetchCapsule(id: UUID) async throws -> Capsule? {
        return storedCapsules[id]
    }

    func fetchCapsulesWithoutSubmissions(IDs: [UUID]) async throws -> [Capsule] {
        return IDs.compactMap { id in
            guard let capsule = storedCapsules[id] else { return nil }
            var copy = capsule
            copy.submissions = []
            return copy
        }
    }

    func fetchBrazilianTime() async throws -> Date {
        // Mock sempre retorna hora "fixa" previsível para testes
        return Date(timeIntervalSince1970: 1_700_000_000)
    }

    // MARK: - Regras de negócio simuladas

    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool {
        didCheckValidOffensive = true

        guard let capsule = storedCapsules[capsuleID] else {
            return false
        }

        let diff = Date().timeIntervalSince(capsule.lastSubmissionDate)
        let limit: TimeInterval = 48 * 60 * 60
        return diff < limit
    }

    func createCapsuleWithSubmissions(
        capsule: Capsule,
        submissions: [Submission],
        images: [UIImage]
    ) async throws -> UUID {
        didCreateCapsuleWithSubmissions = true

        var newCapsule = capsule
        newCapsule.submissions = submissions

        storedCapsules[capsule.id] = newCapsule
        storedSubmissions[capsule.id] = submissions

        return capsule.id
    }

    func checkIfCapsuleIsCompleted(capsuleID: UUID) async throws -> Bool {
        didCheckIfCapsuleIsCompleted = true
        return storedCapsules[capsuleID]?.status == .completed
    }

    func checkIfIncreasesStreak(capsuleID: UUID) async throws {
        didCheckIfIncreasesStreak = true

        guard var capsule = storedCapsules[capsuleID] else { return }
        capsule.offensive += 1
        storedCapsules[capsuleID] = capsule
    }

    // MARK: - Helpers de teste

    func addSubmission(_ submission: Submission) {
        storedSubmissions[submission.capsuleID, default: []].append(submission)

        if var capsule = storedCapsules[submission.capsuleID] {
            capsule.submissions.append(submission)
            capsule.lastSubmissionDate = submission.date
            storedCapsules[submission.capsuleID] = capsule
        }
    }

    func resetTrackers() {
        didCreate = false
        didDelete = false
        didUpdate = false
        didFetchCapsules = false
        didCreateSubmission = false
        didCheckValidOffensive = false
        didCreateCapsuleWithSubmissions = false
        didCheckIfCapsuleIsCompleted = false
        didCheckIfIncreasesStreak = false

        createdCapsule = nil
        updatedCapsule = nil
        deletedCapsuleID = nil
        fetchedCapsuleIDs = []
        createdSubmission = nil
    }

    func createMultipleSubmissions(
        submissions: [Submission],
        capsuleID: UUID,
        images: [UIImage]
    ) async throws {
        didCreateMultipleSubmissions = true
        createdSubmissions = submissions
    }

}

