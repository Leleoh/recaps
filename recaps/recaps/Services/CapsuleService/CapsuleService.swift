//
//  CapsuleService.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
import SwiftUI

class CapsuleService: CapsuleServiceProtocol {
    private let database: CKDatabase
    init(database: CKDatabase = Database.shared.database) {
        self.database = database
    }
    func createCapsule(capsule: Capsule) async throws -> UUID {
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
        
        _ = try await database.save(record)
        
        return capsule.id
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
    
    func createSubmission(submission: Submission, capsuleID: UUID, image: UIImage) async throws {
        let recordID = CKRecord.ID(recordName: submission.id.uuidString)
        let record = CKRecord(recordType: "Submission", recordID: recordID)
        
        record["id"] = submission.id.uuidString as CKRecordValue
        
        if let description = submission.description {
            record["description"] = description as CKRecordValue
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        
        guard
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        do {
            try data.write(to: url)
            let asset = CKAsset(fileURL: url)
            record["image"] = asset
        } catch let error {
            print(error)
        }
        
        record["date"] = submission.date as CKRecordValue
        record["capsuleID"] = capsuleID.uuidString as CKRecordValue
        
        do {
            let savedRecord = try await database.save(record)
            print("Submission salva: \(savedRecord)")
        } catch {
            print("Erro ao salvar a Submission: \(error)")
            throw error
        }
        
    }
    
    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission] {
        let predicate = NSPredicate(format: "capsuleID == %@", capsuleID.uuidString)
        // let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Submission", predicate: predicate)
        
        var submissions: [Submission] = []
        
        let result = try await database.records(matching: query)
        
        for (_, recordResult) in result.matchResults {
            switch recordResult {
            case .success(let record):
                
                let idString = record["id"] as? String ?? ""
                guard let id = UUID(uuidString: idString) else { continue }
                
                let description = record["description"] as? String
                
                let date = record["date"] as? Date ?? Date()
                
                let authorId = record["authorId"] as? String ?? ""
                
                let capsuleIDString = record["capsuleID"] as? String ?? ""
                let capsuleID = UUID(uuidString: capsuleIDString) ?? UUID()
                
                var imageURL: URL? = nil
                if let asset = record["image"] as? CKAsset,
                   let fileURL = asset.fileURL {
                    
                    let localURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(UUID().uuidString).jpg")
                    
                    do {
                        try FileManager.default.copyItem(at: fileURL, to: localURL)
                        imageURL = localURL
                    } catch {
                        print("Erro ao copiar asset: \(error)")
                    }
                }
                
                let submission = Submission(
                    id: id,
                    imageURL: imageURL,
                    description: description,
                    authorId: authorId,
                    date: date,
                    capsuleID: capsuleID
                )
                
                submissions.append(submission)
                
            case .failure(let error):
                print("Erro ao obter registro: \(error)")
            }
        }
        
        return submissions
    }
    
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule] {
        let recordNames = IDs.map { $0.uuidString }
        
        let referenceIDs = recordNames.map { CKRecord.ID(recordName: $0) }
        
        var capsules: [Capsule] = []
        
        let result = try await database.records(for: referenceIDs)
        
        for (_, recordResult) in result {
            switch recordResult {
            case .success(let record):
                
                guard
                    let idString = record["id"] as? String,
                    let id = UUID(uuidString: idString)
                else { continue }
                
                let code = record["code"] as? String ?? ""
                let name = record["name"] as? String ?? ""
                let createdAt = record["createdAt"] as? Date ?? Date()
                let offensive = record["offensive"] as? Int ?? 0
                let lastSubmissionDate = record["lastSubmissionDate"] as? Date ?? Date()
                let validOffensive = record["validOffensive"] as? Bool ?? false
                let lives = record["lives"] as? Int ?? 0
                
                let ownerId = record["ownerId"] as? String ?? ""
                
                let statusRaw = record["status"] as? String ?? ""
                let status = CapsuleStatus(rawValue: statusRaw) ?? .inProgress
                
                let members = record["members"] as? [String] ?? []
                
                let submissions = try await fetchSubmissions(capsuleID: id)
                
                let capsule = Capsule(
                    id: id,
                    code: code,
                    submissions: submissions,
                    name: name,
                    createdAt: createdAt,
                    offensive: offensive,
                    lastSubmissionDate: lastSubmissionDate,
                    validOffensive: validOffensive,
                    lives: lives,
                    members: members,
                    ownerId: ownerId,
                    status: status
                )
                
                capsules.append(capsule)
                
            case .failure(let error):
                print("Erro ao obter Capsule: \(error)")
            }
        }
        
        return capsules
    }
    
    func fetchAllCapsules() async throws -> [Capsule] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Capsule", predicate: predicate)
        
        let result = try await database.records(matching: query)
        var capsules: [Capsule] = []
        
        for (_, recordResult) in result.matchResults {
            switch recordResult {
            case .success(let record):
                guard
                    let idString = record["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let code = record["code"] as? String,
                    let name = record["name"] as? String,
                    let createdAt = record["createdAt"] as? Date,
                    let offensive = record["offensive"] as? Int,
                    let lastSubmissionDate = record["lastSubmissionDate"] as? Date,
                    let validOffensive = record["validOffensive"] as? Bool,
                    let lives = record["lives"] as? Int,
                    let ownerId = record["ownerId"] as? String,
                    let statusRaw = record["status"] as? String,
                    let status = CapsuleStatus(rawValue: statusRaw),
                    let members = record["members"] as? [String]
                else { continue }
                
                let submissions = try await fetchSubmissions(capsuleID: id)
                
                let capsule = Capsule(
                    id: id,
                    code: code,
                    submissions: submissions,
                    name: name,
                    createdAt: createdAt,
                    offensive: offensive,
                    lastSubmissionDate: lastSubmissionDate,
                    validOffensive: validOffensive,
                    lives: lives,
                    members: members,
                    ownerId: ownerId,
                    status: status
                )
                
                capsules.append(capsule)
                
            case .failure(let error):
                print("Erro ao obter Capsule: \(error)")
            }
        }
        
        return capsules
    }
}

