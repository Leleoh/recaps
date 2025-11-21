//
//  CapsuleServiceProtocol.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
protocol CapsuleServiceProtocol {
    func createCapsule(capsule: Capsule) async throws -> CKRecord
    func deleteCapsule(capsuleID: UUID) async throws
    func updateCapsule(capsule: Capsule) async throws
}
