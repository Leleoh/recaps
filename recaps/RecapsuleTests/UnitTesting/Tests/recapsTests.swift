//
//  recapsTests.swift
//  recapsTests
//
//  Created by Fernando Sulzbach on 19/11/25.
//

import Testing
import Foundation
@testable import recaps

@Suite("CloudKitService Tests")
struct CloudKitServiceTests {

    let mockCapsule = Capsule(
        id: UUID(),
        code: "ABCDE",
        name: "Teste",
        createdAt: .now,
        offensive: 0,
        lastSubmissionDate: .now,
        validOffensive: true,
        lives: 3,
        members: [],
        ownerId: " ",
        status: .inProgress
    )

    @Test("Teste: criar cápsula chama o método correto")
    func testCreateCapsule() async throws {
        let mockService = MockCapsuleService()

        try await mockService.createCapsule(capsule: mockCapsule)

        #expect(mockService.didCreate == true)
        #expect(mockService.createdCapsule?.id == mockCapsule.id)
    }

    @Test("Teste: deletar cápsula passa o ID correto")
    func testDeleteCapsule() async throws {
        let mockService = MockCapsuleService()

        try await mockService.deleteCapsule(capsuleID: mockCapsule.id)

        #expect(mockService.didDelete == true)
        #expect(mockService.deletedCapsuleID == mockCapsule.id)
    }

    @Test("Teste: updateCapsule atualiza corretamente")
    func testUpdateCapsule() async throws {
        let mockService = MockCapsuleService()
        try await mockService.updateCapsule(capsule: mockCapsule)

        #expect(mockService.didUpdate == true)
        #expect(mockService.updatedCapsule?.name == mockCapsule.name)
    }
    
    @Test("Teste: fetchSubmissions retorna corretamente")
    func testFetchSubmissions() async throws {

        let mock = MockCKService()

        let capsuleID = UUID()

        let submission1 = Submission(
            id: UUID(),
            imageURL: nil,
            description: "Foto 1",
            authorId: UUID(),
            date: .now,
            capsuleID: capsuleID
        )

        let submission2 = Submission(
            id: UUID(),
            imageURL: nil,
            description: "Foto 2",
            authorId: UUID(),
            date: .now,
            capsuleID: capsuleID
        )

        mock.addSubmission(submission1)
        mock.addSubmission(submission2)

        let result = try await mock.fetchSubmissions(capsuleID: capsuleID)

        #expect(result.count == 2)
        #expect(result.map(\.description) == ["Foto 1", "Foto 2"])
    }
    
    @Test("Teste: fetchCapsules retorna vazio para IDs inexistentes")
    func testFetchCapsulesEmpty() async throws {
        let mock = MockCKService()

        let result = try await mock.fetchCapsules(IDs: [UUID()])

        #expect(result.isEmpty)
    }
    
    @Test("Teste: updateCapsule realmente altera os valores")
    func testUpdateCapsuleChangesValues() async throws {
        let mock = MockCKService()

        var capsule = Capsule(
            id: UUID(),
            code: "ABCDE",
            submissions: [],
            name: "Original",
            createdAt: .now,
            offensive: 0,
            lastSubmissionDate: .now,
            validOffensive: true,
            lives: 3,
            members: [],
            ownerId: UUID(),
            status: .inProgress
        )

        try await mock.createCapsule(capsule: capsule)

        capsule.name = "Alterado"

        try await mock.updateCapsule(capsule: capsule)

        let saved = mock.storedCapsules[capsule.id]

        #expect(saved?.name == "Alterado")
    }
    
    
}
