//
//  CapsuleServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
import SwiftUI

protocol CapsuleServiceProtocol {

    // MARK: - Reading
    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission]
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule]
    func fetchAllCapsules() async throws -> [Capsule]
    func fetchAllCapsulesWithoutSubmissions() async throws -> [Capsule]

    // MARK: - Writing
    func createCapsule(capsule: Capsule) async throws -> UUID
    func deleteCapsule(capsuleID: UUID) async throws
    func updateCapsule(capsule: Capsule) async throws
    func createSubmission(submission: Submission, capsuleID: UUID, image: UIImage) async throws
    func createCapsuleWithSubmissions(capsule: Capsule, submissions: [Submission], images: [UIImage]) async throws -> UUID

    // MARK: - Verification
    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool
    func checkIfCapsuleIsCompleted(capsuleID: UUID) async throws -> Bool
    func checkIfIncreasesStreak(capsuleID: UUID) async throws

}

