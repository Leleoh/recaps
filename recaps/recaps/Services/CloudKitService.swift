//
//  Empty.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 19/11/25.
//

import Foundation
import CloudKit

protocol CKServiceProtocol {
    func createCapsule(capsule: Capsule) async throws
    func deleteCapsule(capsuleID: UUID) async throws
    func updateCapsule(capsule: Capsule) async throws
    
}

@Observable
class CloudKitService: CKServiceProtocol {
    
    let container: CKContainer
    let database: CKDatabase
    
    init() {
        container = CKContainer(identifier: "iCloud.com.Recaps.app")
        database = container.publicCloudDatabase
    }
    
    func createCapsule(capsule: Capsule) async throws {
        //let record = CKRecord(recordType: "Capsule")
        let recordID = CKRecord.ID(recordName: capsule.id.uuidString)
        let record = CKRecord(recordType: "Capsule", recordID: recordID)
        
        record["id"] = capsule.id.uuidString as CKRecordValue
        record["code"] = capsule.code as CKRecordValue
        record["name"] = capsule.name as CKRecordValue
        record["createdAt"] = capsule.createdAt as CKRecordValue
        record["offensive"] = capsule.offensive as CKRecordValue
        record["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
        record["validOffensive"] = capsule.validOffensive as CKRecordValue
        record["lives"] = capsule.lives as CKRecordValue
        record["ownerId"] = capsule.ownerId.uuidString as CKRecordValue
        record["status"] = capsule.status.rawValue as CKRecordValue
        record["members"] = capsule.members.map { $0.uuidString } as CKRecordValue
        
        do {
            let savedRecord = try await database.save(record)
            print("Capsula salva: \(savedRecord)")
        } catch {
            print("Erro ao salvar a Capsula : \(error)")
            throw error
        }
        
    }
    
    func deleteCapsule(capsuleID: UUID) async throws {
        let recordID = CKRecord.ID(recordName: capsuleID.uuidString)
        
        do {
            try await database.deleteRecord(withID: recordID)
            print("Capsula deletada com sucesso: \(capsuleID)")
        } catch {
            print("Erro ao deletar a Capsula: \(error)")
            throw error
        }
    }
    
    func updateCapsule(capsule: Capsule) async throws {
        let recordID = CKRecord.ID(recordName: capsule.id.uuidString)
        
        do {
            let record = try await database.record(for: recordID)
            
            record["code"] = capsule.code as CKRecordValue
            record["name"] = capsule.name as CKRecordValue
            record["createdAt"] = capsule.createdAt as CKRecordValue
            record["offensive"] = capsule.offensive as CKRecordValue
            record["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
            record["validOffensive"] = capsule.validOffensive as CKRecordValue
            record["lives"] = capsule.lives as CKRecordValue
            record["ownerId"] = capsule.ownerId.uuidString as CKRecordValue
            record["status"] = capsule.status.rawValue as CKRecordValue
            record["members"] = capsule.members.map { $0.uuidString } as CKRecordValue
            
            do {
                let savedRecord = try await database.save(record)
                print("Capsula salva: \(savedRecord)")
            } catch {
                print("Erro ao salvar a Capsula : \(error)")
                throw error
            }
        }
    }
}
