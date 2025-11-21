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
}
