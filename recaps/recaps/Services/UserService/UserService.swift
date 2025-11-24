//
//  UserService.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import Foundation
import CloudKit

class UserService: UserServiceProtocol {
    private let database: CKDatabase
    init(database: CKDatabase = Database.shared.database) {
        self.database = database
    }
    
    func getCurrentUser(userId: String) async throws -> User {
        let recordID = CKRecord.ID(recordName: userId)

        let record = try await database.record(for: recordID)

        let name = record["name"] as? String ?? ""
        let email = record["email"] as? String ?? ""
        let capsulesRecords = record["capsules"] as? [CKRecord.ID] ?? []

        let capsules: [UUID] = capsulesRecords.compactMap { recordID in
            UUID(uuidString: recordID.recordName)
        }
        
        return User(
            id: userId,
            name: name,
            email: email,
            capsules: capsules
        )
    }
    
    func createUser(user: User) async throws {
        let recordID = CKRecord.ID(recordName: user.id)
        let record = CKRecord(recordType: "User", recordID: recordID)

        //preencher dados do User
        record["id"] = user.id as CKRecordValue
        record["email"] = user.email as CKRecordValue
        record["name"] = user.name as CKRecordValue

        //salvar usuário
        do {
            let savedRecord = try await database.save(record)
            print("Usuário salvo:", savedRecord.recordID.recordName)
        } catch {
            print("Erro ao salvar o usuário:", error)
            throw error
        }
    }
}
