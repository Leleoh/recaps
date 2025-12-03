//
//  CapsuleServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
import SwiftUI

protocol CapsuleServiceProtocol {
    
    // Escrita
    func createCapsule(capsule: Capsule) async throws -> UUID
    func deleteCapsule(capsuleID: UUID) async throws
    func updateCapsule(capsule: Capsule) async throws
    func createSubmission(submission: Submission, capsuleID: UUID, image: UIImage) async throws
    
    // Leitura
    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission]
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule]
    func fetchAllCapsules() async throws -> [Capsule]
    func fetchAllCapsulesWithoutSubmissions() async throws -> [Capsule]
    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool
}
