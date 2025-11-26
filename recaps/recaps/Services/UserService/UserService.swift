//
//  UserService.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
import Foundation

class UserService: UserServiceProtocol {
    // MARK: Properties
    private let database: CKDatabase
    private let defaults = UserDefaults.standard
    // MARK: Init
    init(database: CKDatabase = Database.shared.database) {
        self.database = database
        self.userId = getUserId()
    }
    var userId: String = ""

    // MARK: Get Current User
    func getCurrentUser() async throws -> User {
        let recordID = CKRecord.ID(recordName: getUserId())
        let record = try await database.record(for: recordID)

        let name = record["name"] as? String ?? ""
        let email = record["email"] as? String ?? ""

        let references = record["capsules"] as? [CKRecord.Reference] ?? []

        let capsuleUUIDs: [UUID] = references.compactMap { ref in
            UUID(uuidString: ref.recordID.recordName)
        }

        return User(
            id: userId,
            name: name,
            email: email,
            capsules: capsuleUUIDs
        )
    }

    // MARK: Create User
    func createUser(user: User) async throws {
        let recordID = CKRecord.ID(recordName: user.id)
        let record = CKRecord(recordType: "User", recordID: recordID)
        
        record["id"] = user.id as CKRecordValue
        record["email"] = user.email as CKRecordValue
        record["name"] = user.name as CKRecordValue

        do {
            let savedRecord = try await database.save(record)
            print("Usuário salvo:", savedRecord.recordID.recordName)
        } catch {
            print("Erro ao salvar o usuário:", error)
            throw error
        }
    }

    // MARK: Update User
    func updateUser(_ user: User, capsules: [UUID]? = nil) async throws {
        let recordID = CKRecord.ID(recordName: user.id)
        let record = try await database.record(for: recordID)

        record["name"] = user.name as CKRecordValue
        record["email"] = user.email as CKRecordValue

        if let capsules = capsules {
            let capsuleRefs = capsules.map { uuid in
                CKRecord.Reference(
                    recordID: CKRecord.ID(recordName: uuid.uuidString),
                    action: .none
                )
            }
            record["capsules"] = capsuleRefs as CKRecordValue
        }

        _ = try await database.save(record)
    }

    // MARK: Local Persistence (Current User)
    func loadUserId() -> String {
        return UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    func saveUserId(_ id: String) {
        defaults.set(id, forKey: "userId")
    }
    func getUserId() -> String {
        defaults.string(forKey: "userId") ?? ""
    }
    func logout() {
        defaults.removeObject(forKey: "userId")
    }

}
