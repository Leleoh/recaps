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
        record["offensiveTarget"] = capsule.offensiveTarget as CKRecordValue
        record["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
        record["validOffensive"] = capsule.validOffensive as CKRecordValue
        record["lives"] = capsule.lives as CKRecordValue
        record["ownerId"] = capsule.ownerId as CKRecordValue
        record["status"] = capsule.status.rawValue as CKRecordValue
        record["members"] = capsule.members as CKRecordValue
        
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
            record["offensiveTarget"] = capsule.offensiveTarget as CKRecordValue
            record["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
            record["validOffensive"] = capsule.validOffensive as CKRecordValue
            record["lives"] = capsule.lives as CKRecordValue
            record["ownerId"] = capsule.ownerId as CKRecordValue
            record["status"] = capsule.status.rawValue as CKRecordValue
            record["members"] = capsule.members as CKRecordValue
            
            do {
                let savedRecord = try await database.save(record)
                print("Capsula salva: \(savedRecord)")
            } catch {
                print("Erro ao atulizar a Capsula : \(error)")
                throw error
            }
        } catch {
            print("Erro ao atualizar a Capsula : \(error)")
            throw error
        }
    }
    
    private func updateLastSubmissionDate(record: CKRecord) async throws {
        
        do {
            
            let brtTime = try await fetchBrazilianTime()
            
            let midnightTime = dateAtMidnight(from: brtTime)
            
            record["lastSubmissionDate"] = midnightTime as CKRecordValue
            
            do {
                let savedRecord = try await database.save(record)
                print("Capsula salva: \(savedRecord)")
            } catch {
                print("Erro ao salvar a Capsula : \(error)")
                throw error
            }
        } catch {
            print("Erro ao atualizar a Capsula : \(error)")
            throw error
        }
    }
    
    private func timeDifferenceFromNow(from date: Date) async throws -> TimeInterval {
        
        // Converter lastSubmissionDate para BRT
        let tz = TimeZone(identifier: "America/Sao_Paulo")!
        let offset = TimeInterval(tz.secondsFromGMT(for: date))
        let lastSubmissionDateBRT = Date(timeInterval: offset, since: date)
        
        let brtServerTime = try await fetchBrazilianTime()
                    
        let difference = brtServerTime.timeIntervalSince(lastSubmissionDateBRT)
        
        print("Horário Atual: \(brtServerTime)")
        print("Diferenca de Tempo: \(difference / 60 / 60)")
        
        return difference
    }
    
    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool {
        let recordID = CKRecord.ID(recordName: capsuleID.uuidString)
        
        do {
            let record = try await database.record(for: recordID)
            
            let isCapsuleCompleted = try await isCapsuleCompleted(record: record)
            
            if isCapsuleCompleted {
                return true
            }
            
            guard
                let lastSubmissionDate = record["lastSubmissionDate"] as? Date
            else {
                return false
            }
            
            let difference = try await timeDifferenceFromNow(from: lastSubmissionDate)
                                    
            let FortyEightHours: TimeInterval = 48 * 60 * 60
            
            print("Horas: \(FortyEightHours / 60 / 60)")
            
            
            if difference >= FortyEightHours {
                print("diferenca maior que 48h")
                let hasRemainingLives = try await consumeCapsuleLive(record: record)
                if !hasRemainingLives {
                    print("Não há mais vidas, resetando contador...")
                    try await resetStreakCounter(record: record)
                    try await updateLastSubmissionDate(record: record)
                }
            }
            
            return difference < FortyEightHours
            
        } catch {
            print("Erro ao verificar cápsula: \(error)")
            throw error
        }
    }
    
    func checkIfCapsuleIsCompleted(capsuleID: UUID) async throws -> Bool {
        let recordID = CKRecord.ID(recordName: capsuleID.uuidString)
        
        do {
            let record = try await database.record(for: recordID)
            
            let isCapsuleCompleted = try await isCapsuleCompleted(record: record)
            
            if isCapsuleCompleted {
                return true
            }
            
            return false
            
        } catch {
            print("Erro ao verificar se cápsula está Completa: \(error)")
            throw error
        }
    }
    
    private func increaseStreak(record: CKRecord) async throws {
        
        if var offensive = record["offensive"] as? Int {
            offensive = offensive + 1
            record["offensive"] = offensive as CKRecordValue
        }
        
        do {
            let savedRecord = try await database.save(record)
            print("Capsula salva: \(savedRecord)")
        } catch {
            print("Erro ao atulizar a Capsula : \(error)")
            throw error
        }
    }
    
    private func isCapsuleCompleted(record: CKRecord) async throws -> Bool {
        
        if let status = record["status"] as? String, let statusEnum = CapsuleStatus(rawValue: status) {
            if statusEnum == .completed  {
                return true
            }
        }
        return false
    }
    
    private func isStreakCompleted(record: CKRecord) async throws -> Bool {
        
        if let offensive = record["offensive"] as? Int,
            let offensiveTarget = record["offensiveTarget"] as? Int {
            if offensive >= offensiveTarget {
                try await changeCapsuleToCompleted(record: record)
                return true
            }
        }
        return false
    }
    
    private func changeCapsuleToCompleted(record: CKRecord) async throws {
        
        record["status"] = CapsuleStatus.completed.rawValue as CKRecordValue
        
        do {
            let savedRecord = try await database.save(record)
            print("Status da Capsula alterado para Completed: \(savedRecord)")
        } catch {
            print("Erro ao atulizar Status da Capsula : \(error)")
            throw error
        }
    }
    
    private func resetStreakCounter(record: CKRecord) async throws {
    
        record["offensive"] = 0 as CKRecordValue
        
        do {
            let savedRecord = try await database.save(record)
            print("Streak Resetado e Capsula Salva: \(savedRecord)")
        } catch {
            print("Erro ao atulizar a Capsula : \(error)")
            throw error
        }
    }
    
    private func consumeCapsuleLive(record: CKRecord) async throws -> Bool {
            
        if var capsuleLives = record["lives"] as? Int {
            
            if capsuleLives == 0 {
                return false
            }
            
            capsuleLives = capsuleLives - 1
            
            record["lives"] = capsuleLives as CKRecordValue
            
            do {
                let savedRecord = try await database.save(record)
                print("Capsula com vida consumida: \(savedRecord)")
                return true
            } catch {
                print("Erro ao consumir a vida da Capsula : \(error)")
                throw error
            }
        }
        
        return false
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
            try await checkIfIncreasesStreak(capsuleID: capsuleID)
            print("Submission salva: \(savedRecord)")
        } catch {
            print("Erro ao salvar a Submission: \(error)")
            throw error
        }
        
    }
    
    func checkIfIncreasesStreak(capsuleID: UUID) async throws {
        let recordID = CKRecord.ID(recordName: capsuleID.uuidString)
        
        do {
            let record = try await database.record(for: recordID)
            
            if let lastSubmissionDate = record["lastSubmissionDate"] as? Date {
                
                let difference = try await timeDifferenceFromNow(from: lastSubmissionDate)
                
                let FortyEightHours: TimeInterval = 48 * 60 * 60
                let TwentyFourHours: TimeInterval = 24 * 60 * 60
                                
                if difference >= FortyEightHours {
                    print("diferenca maior que 48h")
                    let hasRemainingLives = try await consumeCapsuleLive(record: record)
                    if !hasRemainingLives {
                        print("Não há mais vidas, resetando contador...")
                        try await resetStreakCounter(record: record)
                    }
                    try await updateLastSubmissionDate(record: record)
                }
                
                if difference >= TwentyFourHours {
                    print("diferenca maior que 24h")
                    try await increaseStreak(record: record)
                    try await updateLastSubmissionDate(record: record)
                }
                
            }
            
        } catch {
            print("Erro ao verificar cápsula: \(error)")
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
                let offensiveTarget = record["offensiveTarget"] as? Int ?? 0
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
                    offensiveTarget: offensiveTarget,
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
                    let offensiveTarget = record["offensiveTarget"] as? Int,
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
                    offensiveTarget: offensiveTarget,
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
    
    func fetchAllCapsulesWithoutSubmissions() async throws -> [Capsule] {
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
                    let offensiveTarget = record["offensiveTarget"] as? Int,
                    let lastSubmissionDate = record["lastSubmissionDate"] as? Date,
                    let validOffensive = record["validOffensive"] as? Bool,
                    let lives = record["lives"] as? Int,
                    let ownerId = record["ownerId"] as? String,
                    let statusRaw = record["status"] as? String,
                    let status = CapsuleStatus(rawValue: statusRaw),
                    let members = record["members"] as? [String]
                else { continue }
                
                
                let capsule = Capsule(
                    id: id,
                    code: code,
                    submissions: [],
                    name: name,
                    createdAt: createdAt,
                    offensive: offensive,
                    offensiveTarget: offensiveTarget,
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

    private func fetchBrazilianTime() async throws -> Date {
        let url = URL(string: "https://recaps-time.recaps-academy-utc.workers.dev")!

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(domain: "TimeAPIError", code: -1)
        }

        let decoded = try JSONDecoder().decode(TimeResponse.self, from: data)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let utcDate = formatter.date(from: decoded.utc) else {
            throw NSError(domain: "TimeAPIParse", code: -1)
        }

        let tz = TimeZone(identifier: "America/Sao_Paulo")!
        let offset = TimeInterval(tz.secondsFromGMT(for: utcDate))
        let brasiliaDate = Date(timeInterval: offset, since: utcDate)

        return brasiliaDate
    }
    
    private func dateAtMidnight(from utcDate: Date) -> Date {
        
        let calendar = Calendar(identifier: .gregorian)

        let components = calendar.dateComponents([.year, .month, .day], from: utcDate)

        return calendar.date(from: components)!
    }
}

struct TimeResponse: Codable {
    let utc: String
}

