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
    
    func createCapsuleWithSubmissions(capsule: Capsule, submissions: [Submission], images: [UIImage]) async throws -> UUID {
        
        print("\n🚀 [DEBUG] Iniciando createCapsuleWithSubmissions")
        print("📊 Dados recebidos: \(submissions.count) submissions e \(images.count) imagens")
        
        // 1. Validação inicial
        if submissions.count != images.count {
            print("⚠️ [ALERTA] O número de submissions difere do número de imagens!")
        }

        var recordsToSave: [CKRecord] = []
        
        // 1. CAPSULE RECORD
        print("📦 Preparando Capsule Record: \(capsule.id.uuidString)")
        let capsuleRecordID = CKRecord.ID(recordName: capsule.id.uuidString)
        let capsuleRecord = CKRecord(recordType: "Capsule", recordID: capsuleRecordID)

        capsuleRecord["id"] = capsule.id.uuidString as CKRecordValue
        capsuleRecord["code"] = capsule.code as CKRecordValue
        capsuleRecord["name"] = capsule.name as CKRecordValue
        capsuleRecord["createdAt"] = capsule.createdAt as CKRecordValue
        capsuleRecord["offensive"] = capsule.offensive as CKRecordValue
        capsuleRecord["offensiveTarget"] = capsule.offensiveTarget as CKRecordValue
        capsuleRecord["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
        capsuleRecord["validOffensive"] = capsule.validOffensive as CKRecordValue
        capsuleRecord["lives"] = capsule.lives as CKRecordValue
        capsuleRecord["ownerId"] = capsule.ownerId as CKRecordValue
        capsuleRecord["status"] = capsule.status.rawValue as CKRecordValue
        capsuleRecord["members"] = capsule.members as CKRecordValue
        
        recordsToSave.append(capsuleRecord)
        

        // 2. SUBMISSION RECORDS
        for (index, submission) in submissions.enumerated() {
            print("🔹 Processando submission \(index + 1)/\(submissions.count) - ID: \(submission.id)")
            
            let submissionRecordID = CKRecord.ID(recordName: submission.id.uuidString)
            let submissionRecord = CKRecord(recordType: "Submission", recordID: submissionRecordID)

            submissionRecord["id"] = submission.id.uuidString as CKRecordValue
            submissionRecord["authorId"] = submission.authorId as CKRecordValue
            submissionRecord["date"] = submission.date as CKRecordValue
            submissionRecord["capsuleID"] = capsule.id.uuidString as CKRecordValue

            if let desc = submission.description {
                submissionRecord["description"] = desc as CKRecordValue
            }

            // 💾 salvar imagem temporária
            let fileName = "\(UUID().uuidString).jpg"
            
            // Verificação de segurança de índice
            if index < images.count {
                if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
                   let data = images[index].jpegData(compressionQuality: 0.3) // ⚠️ 1.0 gera arquivos grandes
                {
                    do {
                        try data.write(to: url)
                        submissionRecord["image"] = CKAsset(fileURL: url)
                        print("   ✅ Imagem convertida e salva em temp: \(fileName)")
                        print("   📏 Tamanho do arquivo: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                    } catch {
                        print("   ❌ Erro ao escrever arquivo no disco: \(error)")
                    }
                } else {
                    print("   ❌ FALHA: Não foi possível gerar jpegData para a imagem \(index)")
                }
            } else {
                 print("   ❌ ERRO CRÍTICO: Índice \(index) fora dos limites do array de imagens!")
            }

            recordsToSave.append(submissionRecord)
        }

        print("📤 Enviando operação para o CloudKit com \(recordsToSave.count) records...")
        
        // 3. ÚNICA OPERAÇÃO: salvar tudo junto
        return try await withCheckedThrowingContinuation { continuation in
            let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)

            operation.savePolicy = .allKeys
            operation.isAtomic = false  // se alguma falhar, tenta salvar as outras

            operation.modifyRecordsCompletionBlock = { saved, deleted, error in
                
                // Log de Sucesso (parcial ou total)
                if let savedRecords = saved {
                    print("✅ CloudKit confirmou o salvamento de \(savedRecords.count) records.")
                    for record in savedRecords {
                        print("   Reconfirmado: \(record.recordType) - \(record.recordID.recordName)")
                    }
                }

                if let error = error {
                    print("❌ ERRO NO CLOUDKIT: \(error.localizedDescription)")
                    
                    // 🕵️‍♂️ DEBUG DE ERRO PARCIAL (Muito Importante)
                    if let ckError = error as? CKError {
                        if ckError.code == .partialFailure {
                            print("⚠️ O erro foi PARCIAL. Alguns itens falharam:")
                            if let partialErrors = ckError.partialErrorsByItemID {
                                for (id, err) in partialErrors {
                                    print("   💀 Falha no ID \(id): \(err)")
                                }
                            }
                        } else if ckError.code == .limitExceeded {
                            print("⚠️ O payload total é muito grande para uma única requisição.")
                        }
                    }
                    
                    continuation.resume(throwing: error)
                    return
                }

                print("🏁 Operação finalizada com sucesso total.")
                continuation.resume(returning: capsule.id)
            }

            database.add(operation)
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
            record["offensiveTarget"] = capsule.offensiveTarget as CKRecordValue
            record["lastSubmissionDate"] = capsule.lastSubmissionDate as CKRecordValue
            record["validOffensive"] = capsule.validOffensive as CKRecordValue
            record["lives"] = capsule.lives as CKRecordValue
            record["ownerId"] = capsule.ownerId as CKRecordValue
            record["status"] = capsule.status.rawValue as CKRecordValue
            record["members"] = capsule.members as CKRecordValue
            record["blacklisted"] = capsule.blacklisted.map { $0.uuidString } as CKRecordValue
            
            if let dailyGameSubmission = capsule.dailyGameSubmission {
                record["dailyGameSubmission"] = dailyGameSubmission.uuidString as CKRecordValue
            }
            
            if let dailyGameDate = capsule.dailyGameDate {
                record["dailyGameDate"] = dailyGameDate as CKRecordValue
            }
            
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
            
            let isStreakCompleted = try await isStreakCompleted(record: record)
            
            if isStreakCompleted {
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
        record["authorId"] = submission.authorId as CKRecordValue
        
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
    
    func createMultipleSubmissions(submissions: [Submission], capsuleID: UUID, images: [UIImage]) async throws {
        
        guard submissions.count == images.count else {
            print("Erro: número de submissions != número de imagens")
            return
        }
        
        var records: [CKRecord] = []
        var tempFiles: [URL] = []
        
        for (index, submission) in submissions.enumerated() {
            let image = images[index]
            
            let recordID = CKRecord.ID(recordName: submission.id.uuidString)
            let record = CKRecord(recordType: "Submission", recordID: recordID)
            
            record["id"] = submission.id.uuidString as CKRecordValue
            record["authorId"] = submission.authorId as CKRecordValue
            
            if let description = submission.description {
                record["description"] = description as CKRecordValue
            }
            
            // Salvar imagem temporariamente
            let fileName = "\(UUID().uuidString).jpg"
            guard
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                    .first?
                    .appendingPathComponent(fileName),
                let data = image.jpegData(compressionQuality: 1.0)
            else { continue }
            
            do {
                try data.write(to: url)
                let asset = CKAsset(fileURL: url)
                record["image"] = asset
                tempFiles.append(url)
            } catch {
                print("Erro ao escrever imagem: \(error)")
            }
            
            record["date"] = submission.date as CKRecordValue
            record["capsuleID"] = capsuleID.uuidString as CKRecordValue
            
            records.append(record)
        }
        
        // ----------- SALVANDO EM LOTE -----------
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        operation.isAtomic = false  // se 1 falhar, as outras ainda salvam
        
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    Task {
                        try? await self.checkIfIncreasesStreak(capsuleID: capsuleID)
                    }
                    
                    // Remover arquivos temporários
                    tempFiles.forEach { try? FileManager.default.removeItem(at: $0) }
                    
                    continuation.resume()
                    
                case .failure(let error):
                    print("Erro ao salvar submissions em lote: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
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
    
    func fetchSubmissions(capsuleID: UUID, limit: Int? = nil) async throws -> [Submission] {
        let predicate = NSPredicate(format: "capsuleID == %@", capsuleID.uuidString)
        let query = CKQuery(recordType: "Submission", predicate: predicate)
        
        // Add sorting to get the oldest submissions
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        var submissions: [Submission] = []
        
        let result: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
        
        if let limit = limit {
            result = try await database.records(matching: query, resultsLimit: limit)
        } else {
            result = try await database.records(matching: query)
        }
        
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
    
    func fetchSubmission(id: UUID) async throws -> Submission? {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        let result = try await database.record(for: recordID)
        
        guard
            let idString = result["id"] as? String,
            let id = UUID(uuidString: idString)
        else { return nil }
        
        let description = result["description"] as? String
        let date = result["date"] as? Date ?? Date()
        let authorId = result["authorId"] as? String ?? ""
        
        let capsuleIDString = result["capsuleID"] as? String ?? ""
        let capsuleID = UUID(uuidString: capsuleIDString) ?? UUID()
        
        var imageURL: URL? = nil
        if let asset = result["image"] as? CKAsset,
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
        
        return submission
    }
    
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule] {
        let recordNames = IDs.map { $0.uuidString }
        
        let referenceIDs = recordNames.map { CKRecord.ID(recordName: $0) }
        
        var capsules: [Capsule] = []
        
        let result = try await database.records(for: referenceIDs,)
        
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
                
                let submissions = try await fetchSubmissions(capsuleID: id, limit: 3)
                
                let blacklistedStrings = record["blacklisted"] as? [String] ?? []
                let blacklisted = blacklistedStrings.compactMap { UUID(uuidString: $0) }
                
                let dailyGameDate = record["dailyGameDate"] as? Date ?? nil
                let dailyGameSubmissionString = record["dailyGameSubmission"] as? String ?? nil
                
                var dailyGameSubmission = nil as UUID?
                
                if let dailyGameSubmissionString {
                    dailyGameSubmission = UUID(uuidString: dailyGameSubmissionString)
                }

                
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
                    status: status,
                    dailyGameDate: dailyGameDate,
                    dailyGameSubmission: dailyGameSubmission,
                    blacklisted: blacklisted,
                    
                )
                
                capsules.append(capsule)
                
            case .failure(let error):
                print("Erro ao obter Capsule: \(error)")
            }
        }
        
        return capsules
    }
    
    func fetchCapsule(id: UUID) async throws -> Capsule? {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        let result = try await database.record(for: recordID)
        
        guard
            let idString = result["id"] as? String,
            let id = UUID(uuidString: idString)
        else { return nil }
        
        let code = result["code"] as? String ?? ""
        let name = result["name"] as? String ?? ""
        let createdAt = result["createdAt"] as? Date ?? Date()
        let offensive = result["offensive"] as? Int ?? 0
        let offensiveTarget = result["offensiveTarget"] as? Int ?? 0
        let lastSubmissionDate = result["lastSubmissionDate"] as? Date ?? Date()
        let validOffensive = result["validOffensive"] as? Bool ?? false
        let lives = result["lives"] as? Int ?? 0
        
        let ownerId = result["ownerId"] as? String ?? ""
        
        let statusRaw = result["status"] as? String ?? ""
        let status = CapsuleStatus(rawValue: statusRaw) ?? .inProgress
        
        let members = result["members"] as? [String] ?? []
        
        let blacklisted = result["blacklisted"] as? [UUID] ?? []
        
        let submissions = try await fetchSubmissions(capsuleID: id)
        
        let dailyGameDate = result["dailyGameDate"] as? Date ?? nil
        let dailyGameSubmissionString = result["dailyGameSubmission"] as? String ?? nil
        
        var dailyGameSubmission = nil as UUID?
        
        if let dailyGameSubmissionString {
            dailyGameSubmission = UUID(uuidString: dailyGameSubmissionString)
        }
        
        
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
            status: status,
            dailyGameDate: dailyGameDate,
            dailyGameSubmission: dailyGameSubmission,
            blacklisted: blacklisted,
            
        )
        
        return capsule
    }
    
    func fetchCapsulesWithoutSubmissions(IDs: [UUID]) async throws -> [Capsule] {
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
                
                let blacklisted = record["blacklisted"] as? [UUID] ?? []
                
                let members = record["members"] as? [String] ?? []
                
                let dailyGameDate = record["dailyGameDate"] as? Date ?? nil
                let dailyGameSubmissionString = record["dailyGameSubmission"] as? String ?? nil
                
                var dailyGameSubmission = nil as UUID?
                
                if let dailyGameSubmissionString {
                    dailyGameSubmission = UUID(uuidString: dailyGameSubmissionString)
                }
                
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
                    status: status,
                    dailyGameDate: dailyGameDate,
                    dailyGameSubmission: dailyGameSubmission,
                    blacklisted: blacklisted,
                    
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
                let blacklistedStrings = record["blacklisted"] as? [String] ?? []
                let blacklisted = blacklistedStrings.compactMap { UUID(uuidString: $0) }
                            
                
                let submissions = try await fetchSubmissions(capsuleID: id)
                
                let dailyGameDate = record["dailyGameDate"] as? Date ?? nil
                let dailyGameSubmissionString = record["dailyGameSubmission"] as? String ?? nil
                
                var dailyGameSubmission = nil as UUID?
                
                if let dailyGameSubmissionString {
                    dailyGameSubmission = UUID(uuidString: dailyGameSubmissionString)
                }
                
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
                    status: status,
                    dailyGameDate: dailyGameDate,
                    dailyGameSubmission: dailyGameSubmission,
                    blacklisted: blacklisted,
                    
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
                    status: status,
                    blacklisted: []
                    
                )
                
                capsules.append(capsule)
                
            case .failure(let error):
                print("Erro ao obter Capsule: \(error)")
            }
        }
        
        return capsules
    }
    
    func addSubmissionToDailyGameAndBlacklist(capsule: Capsule, submissionId: UUID) async throws {
        var updatedCapsule = capsule
        print ("Adding \(submissionId) to blacklist")
        
        do {
            updatedCapsule.dailyGameDate = try await fetchBrazilianTime()
        } catch {
            updatedCapsule.dailyGameDate = Date()
        }
        
        updatedCapsule.dailyGameSubmission = submissionId
        
        
        if !updatedCapsule.blacklisted.contains(submissionId) {
            updatedCapsule.blacklisted.append(submissionId)
        }

        try await updateCapsule(capsule: updatedCapsule)
        print(updatedCapsule)
    }
    
    func fetchPossibleSubmissions(capsule: Capsule) async throws -> [Submission] {
        let blacklisted = Set(capsule.blacklisted)
        print("blacklisted: \(blacklisted)")
                
        let allSubmissions = try await fetchSubmissions(capsuleID: capsule.id)
        
        return allSubmissions.filter { submission in
            !blacklisted.contains(submission.id)
        }
    }


    func fetchBrazilianTime() async -> Date {
        do {
            let url = URL(string: "https://recaps-time.recaps-academy-utc.workers.dev")!
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return getBrazilianDate()
            }
            
            let decoded = try JSONDecoder().decode(TimeResponse.self, from: data)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            guard let utcDate = formatter.date(from: decoded.utc) else {
                return getBrazilianDate()
            }
            
            let tz = TimeZone(identifier: "America/Sao_Paulo")!
            let offset = TimeInterval(tz.secondsFromGMT(for: utcDate))
            let brasiliaDate = Date(timeInterval: offset, since: utcDate)
            
            return brasiliaDate
            
        } catch {
            print("Failed to fetch Brazilian time: \(error). Using local time converted to Brazilian timezone.")
            return getBrazilianDate()
        }
    }
    
    func fetchLastSubmission(capsuleID: UUID) async throws -> Submission? {
        let predicate = NSPredicate(format: "capsuleID == %@", capsuleID.uuidString)
        let query = CKQuery(recordType: "Submission", predicate: predicate)

        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let result = try await database.records(matching: query, resultsLimit: 1)

        for (_, recordResult) in result.matchResults {
            if case .success(let record) = recordResult {
                
                let idString = record["id"] as? String ?? ""
                guard let id = UUID(uuidString: idString) else { return nil }
                
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

                    try? FileManager.default.copyItem(at: fileURL, to: localURL)
                    imageURL = localURL
                }

                return Submission(
                    id: id,
                    imageURL: imageURL,
                    description: description,
                    authorId: authorId,
                    date: date,
                    capsuleID: capsuleID
                )
            }
        }
        return nil
    }


    // Helper function to get current date in Brazilian timezone
    private func getBrazilianDate() -> Date {
        let now = Date()
        let tz = TimeZone(identifier: "America/Sao_Paulo")!
        let offset = TimeInterval(tz.secondsFromGMT(for: now))
        return Date(timeInterval: offset, since: now)
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

