//
//  CapsuleService.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import Foundation
import CloudKit
class CapsuleService: CapsuleServiceProtocol {
    private let database: CKDatabase
    init(database: CKDatabase = Database.shared.database) {
        self.database = database
    }
    func createCapsule(capsule: Capsule) async throws -> CKRecord {
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
        record["ownerId"] = capsule.ownerId as CKRecordValue
        record["status"] = capsule.status.rawValue as CKRecordValue
        record["members"] = capsule.members.map { $0 } as CKRecordValue

        do {
            let savedRecord = try await database.save(record)
            print("Capsula salva: \(savedRecord)")
            return savedRecord
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
            record["lastSubmissionDate"] =
                capsule.lastSubmissionDate as CKRecordValue
            record["validOffensive"] = capsule.validOffensive as CKRecordValue
            record["lives"] = capsule.lives as CKRecordValue
            record["ownerId"] = capsule.ownerId as CKRecordValue
            record["status"] = capsule.status.rawValue as CKRecordValue
            record["members"] = capsule.members.map { $0 } as CKRecordValue

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
