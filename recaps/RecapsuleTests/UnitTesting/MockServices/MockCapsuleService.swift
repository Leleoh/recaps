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
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    
    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?
    
    func createCapsule(capsule: recaps.Capsule) async throws -> CKRecord {
        didCreate = true
        createdCapsule = capsule
        
        let record = CKRecord(recordType: "Capsule", recordID: CKRecord.ID(recordName: capsule.id.uuidString))
        return record
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
