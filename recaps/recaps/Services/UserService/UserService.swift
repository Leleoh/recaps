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
        guard !userId.isEmpty else {
            print("Erro: Tentativa de buscar usuário sem ID local (Não logado).")
            throw NSError(domain: "UserService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuário não logado."])
        }
        
        let recordID = CKRecord.ID(recordName: userId)
        
        do {
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
        } catch {
            print("Erro ao buscar o usuário:", error)
            throw error
        }
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
    
    func updateUser(
        _ user: User,
        name: String? = nil,
        email: String? = nil,
        capsules: [UUID]? = nil
    ) async throws -> User {
        
        let recordID = CKRecord.ID(recordName: user.id)
        let record = try await database.record(for: recordID)
        
        if let name = name {
            record["name"] = name as CKRecordValue
        }
        
        if let email = email {
            record["email"] = email as CKRecordValue
        }
        
        if let capsules = capsules {
            let capsuleRefs = capsules.map { uuid in
                CKRecord.Reference(
                    recordID: CKRecord.ID(recordName: uuid.uuidString),
                    action: .none
                )
            }
            record["capsules"] = capsuleRefs as CKRecordValue
        }
        
        let saved = try await database.save(record)
        
        let savedRefs = saved["capsules"] as? [CKRecord.Reference] ?? []
        let savedCapsules = savedRefs.map { UUID(uuidString: $0.recordID.recordName)! }
        
        return User(
            id: saved.recordID.recordName,
            name: saved["name"] as? String ?? "",
            email: saved["email"] as? String ?? "",
            capsules: savedCapsules
        )
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
