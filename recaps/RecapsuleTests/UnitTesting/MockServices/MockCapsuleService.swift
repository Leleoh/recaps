//
//  MockCKService.swift
//  recaps
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Foundation
import CloudKit
@testable import recaps
import UIKit

class MockCapsuleService: CapsuleServiceProtocol {
    
    // MARK: - Trackers
    var didCreate = false
    var didDelete = false
    var didUpdate = false
    var didFetchCapsules = false
    var didCreateSubmission = false
    var didCheckValidOffensive = false
    
    var createdCapsule: Capsule?
    var updatedCapsule: Capsule?
    var deletedCapsuleID: UUID?
    var fetchedCapsuleIDs: [UUID] = []
    var createdSubmission: Submission?

    // MARK: - State interno
    var storedCapsules: [UUID: Capsule] = [:]
    var storedSubmissions: [UUID: [Submission]] = [:]

    // MARK: - Criação, atualização, deleção
    func createCapsule(capsule: Capsule) async throws -> UUID {
        didCreate = true
        createdCapsule = capsule
        storedCapsules[capsule.id] = capsule
        return capsule.id
    }
    
    func updateCapsule(capsule: Capsule) async throws {
        didUpdate = true
        updatedCapsule = capsule
        storedCapsules[capsule.id] = capsule
    }
    
    func deleteCapsule(capsuleID: UUID) async throws {
        didDelete = true
        deletedCapsuleID = capsuleID
        storedCapsules.removeValue(forKey: capsuleID)
    }

    // MARK: - Submissions
    func createSubmission(submission: Submission, capsuleID: UUID, image: UIImage) async throws {
        didCreateSubmission = true
        createdSubmission = submission
        storedSubmissions[capsuleID, default: []].append(submission)
        
        // Também atualizar a capsule com a submission se existir
        if var capsule = storedCapsules[capsuleID] {
            capsule.submissions.append(submission)
            capsule.lastSubmissionDate = submission.date
            storedCapsules[capsuleID] = capsule
        }
    }

    // MARK: - Fetching
    func fetchCapsules(IDs: [UUID]) async throws -> [Capsule] {
        didFetchCapsules = true
        fetchedCapsuleIDs = IDs
        return IDs.compactMap { storedCapsules[$0] }
    }
    
    func fetchAllCapsules() async throws -> [Capsule] {
        didFetchCapsules = true
        return Array(storedCapsules.values)
    }

    func fetchAllCapsulesWithoutSubmissions() async throws -> [Capsule] {
        didFetchCapsules = true
        return storedCapsules.values.map { capsule in
            Capsule(
                id: capsule.id,
                code: capsule.code,
                submissions: [],
                name: capsule.name,
                createdAt: capsule.createdAt,
                offensive: capsule.offensive,
                offensiveTarget: capsule.offensiveTarget,
                lastSubmissionDate: capsule.lastSubmissionDate,
                validOffensive: capsule.validOffensive,
                lives: capsule.lives,
                members: capsule.members,
                ownerId: capsule.ownerId,
                status: capsule.status
            )
        }
    }
    
    func fetchSubmissions(capsuleID: UUID) async throws -> [Submission] {
        return storedSubmissions[capsuleID] ?? []
    }
    
    // MARK: - Implementação do método exigido pelo protocolo
    // Retorna `true` se a cápsula existir e tiver `lastSubmissionDate` dentro das últimas 48 horas.
    // Esse comportamento é simples e suficiente para testes unitários; ajuste conforme necessário.
    func checkIfCapsuleIsValidOffensive(capsuleID: UUID) async throws -> Bool {
        didCheckValidOffensive = true
        
        guard let capsule = storedCapsules[capsuleID] else {
            return false
        }
        
        let last = capsule.lastSubmissionDate
        
        let difference = Date().timeIntervalSince(last)
        let fortyEightHours: TimeInterval = 48 * 60 * 60
        return difference < fortyEightHours
    }
    
    // MARK: - Helpers de teste
    func addSubmission(_ submission: Submission) {
        storedSubmissions[submission.capsuleID, default: []].append(submission)
        if var capsule = storedCapsules[submission.capsuleID] {
            capsule.submissions.append(submission)
            capsule.lastSubmissionDate = submission.date
            storedCapsules[submission.capsuleID] = capsule
        }
    }
    
    func resetTrackers() {
        didCreate = false
        didDelete = false
        didUpdate = false
        didFetchCapsules = false
        didCreateSubmission = false
        didCheckValidOffensive = false
        createdCapsule = nil
        updatedCapsule = nil
        deletedCapsuleID = nil
        fetchedCapsuleIDs = []
        createdSubmission = nil
    }
}
