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
            let capsulesRefs = record["capsules"] as? [CKRecord.Reference] ?? []
            let openCapsulesRefs = record["openCapsules"] as? [CKRecord.Reference] ?? []
            
            let capsules: [UUID] = capsulesRefs.compactMap { ref in
                UUID(uuidString: ref.recordID.recordName)
            }
            
            let openCapsules: [UUID] = openCapsulesRefs.compactMap { ref in
                UUID(uuidString: ref.recordID.recordName)
            }
            
            return User(
                id: userId,
                name: name,
                email: email,
                capsules: capsules,
                openCapsules: openCapsules
            )
            
        } catch {
            print("Erro ao buscar o usuário:", error)
            throw error
        }
    }
    
    // MARK: Get User
    func getUser(with id: String) async throws -> User {
        let recordID = CKRecord.ID(recordName: id)
        let record = try await database.record(for: recordID)
        
        let id = record.recordID.recordName
        let name = record["name"] as? String ?? ""
        let email = record["email"] as? String ?? ""
        let capsulesStrings = record["capsules"] as? [String] ?? []
        let capsules = capsulesStrings.compactMap { UUID(uuidString: $0) }
        
        let openCapsulesStrings = record["openCapsules"] as? [String] ?? []
        let openCapsules = openCapsulesStrings.compactMap { UUID(uuidString: $0) }


        return User(
            id: id,
            name: name,
            email: email,
            capsules: capsules,
            openCapsules: openCapsules

        )

    }
    
    func getUsers(IDs: [String]) async throws -> [User] {
        let referenceIDs = IDs.map { CKRecord.ID(recordName: $0) }
        
        var users: [User] = []
        
        let result = try await database.records(for: referenceIDs)
        
        for (_, recordResult) in result {
            switch recordResult {
            case .success(let record):
                
                let id = record.recordID.recordName
                let name = record["name"] as? String ?? ""
                let email = record["email"] as? String ?? ""
                
                let capsulesStrings = record["capsules"] as? [String] ?? []
                let capsules = capsulesStrings.compactMap { UUID(uuidString: $0) }
                
                let openCapsulesStrings = record["openCapsules"] as? [String] ?? []
                let openCapsules = openCapsulesStrings.compactMap { UUID(uuidString: $0) }
                
                let user = User(
                    id: id,
                    name: name,
                    email: email,
                    capsules: capsules,
                    openCapsules: openCapsules
                )
                
                users.append(user)
                
            case .failure(let error):
                print("Erro ao obter User: \(error)")
                throw error
            }
        }
        
        return users
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
        capsules: [UUID]? = nil,
        openCapsules: [UUID]? = nil
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
        
        if let openCapsules = openCapsules {
            let openCapsuleRefs = openCapsules.map { uuid in
                CKRecord.Reference(
                    recordID: CKRecord.ID(recordName: uuid.uuidString),
                    action: .none
                )
            }
            record["openCapsules"] = openCapsuleRefs as CKRecordValue
        }
        
        let saved = try await database.save(record)
        
        let savedCaps = (saved["capsules"] as? [CKRecord.Reference] ?? [])
                    .compactMap { UUID(uuidString: $0.recordID.recordName) }
        
        let savedOpenCapsulesRefs = saved["openCapsules"] as? [CKRecord.Reference] ?? []
        let savedOpenCapsules = savedOpenCapsulesRefs.map { UUID(uuidString: $0.recordID.recordName)! }
        
        return User(
            id: saved.recordID.recordName,
            name: saved["name"] as? String ?? "",
            email: saved["email"] as? String ?? "",
            capsules: savedCaps,
            openCapsules: savedOpenCapsules

        )
    }
    
    func deleteUser() async throws {
            let id = getUserId()
            
            guard !id.isEmpty else { return }
            
            let recordID = CKRecord.ID(recordName: id)
            
            try await database.deleteRecord(withID: recordID)
            
            print("Usuário deletado:", id)
            logout()
        }

    // MARK: Switch Capsule from Completed to Open in User Model
    func changeCompletedCapsuleToOpenCapsule(user: User, capsuleId: UUID) async throws {
        let recordID = CKRecord.ID(recordName: user.id)
        let record = try await database.record(for: recordID)
        
        var capsuleRefs = record["capsules"] as? [CKRecord.Reference] ?? []
        var openCapsuleRefs = record["openCapsules"] as? [CKRecord.Reference] ?? []
        
        capsuleRefs.removeAll { $0.recordID.recordName == capsuleId.uuidString }
        
        if !openCapsuleRefs.contains(where: { $0.recordID.recordName == capsuleId.uuidString }) {
            let newRef = CKRecord.Reference(
                recordID: CKRecord.ID(recordName: capsuleId.uuidString),
                action: .none
            )
            openCapsuleRefs.append(newRef)
        }
        
        record["capsules"] = capsuleRefs as CKRecordValue
        record["openCapsules"] = openCapsuleRefs as CKRecordValue
        
        do {
            try await database.save(record)
            print("Usuário atualizada:", capsuleId)
        } catch {
            throw error
        }
    }

    
    // MARK: Local Persistence (Current User)
    func loadUserId() -> String? {
        UserDefaults.standard.string(forKey: "userId")
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
