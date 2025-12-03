//
//  OpenedCapsuleViewModelTests.swift
//  recapsTests
//
//  Created by Leonel Ferraz Hernandez on 03/12/25.
//

import XCTest
@testable import recaps

@MainActor
final class OpenedCapsuleViewModelTests: XCTestCase {
    
    var viewModel: OpenedCapsuleViewModel!
    var mockService: MockCapsuleService!
    
    override func setUp() {
        super.setUp()
        mockService = MockCapsuleService()
        viewModel = OpenedCapsuleViewModel(capsuleService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchSubmissionsSuccess() async {
            let idCapsula = UUID()
            let dummySubmission = Submission(
                id: UUID(),
                imageURL: nil,
                description: "Teste",
                authorId: "User1",
                date: Date(),
                capsuleID: idCapsula
            )
            
            
            mockService.mockSubmissionsToReturn = [dummySubmission]
            mockService.shouldReturnError = false

            // Act (Ação)
            await viewModel.fetchSubmissions(for: idCapsula)

            // Assert (Verificação)
            XCTAssertFalse(viewModel.isLoading, "O loading deve ser false após o fim da busca")
            XCTAssertNil(viewModel.errorMessage, "Não deve haver mensagem de erro no sucesso")
            XCTAssertEqual(viewModel.submissions.count, 1, "Deve ter retornado 1 submissão")
            XCTAssertEqual(viewModel.submissions.first?.description, "Teste", "A descrição deve bater com o mock")
        }
    
    func testFetchSubmissionsFailure() async {
            // Arrange
            mockService.shouldReturnError = true // Configura o Mock para dar erro

            // Act
            await viewModel.fetchSubmissions(for: UUID())

            // Assert
            XCTAssertFalse(viewModel.isLoading, "O loading deve ser false mesmo com erro")
            XCTAssertTrue(viewModel.submissions.isEmpty, "A lista deve estar vazia em caso de erro")
            XCTAssertNotNil(viewModel.errorMessage, "A mensagem de erro deve ser preenchida")
            XCTAssertEqual(viewModel.errorMessage, "Erro ao carregar memórias.", "A mensagem de erro deve ser a esperada")
        }
    
    func testInitialState() {
            XCTAssertTrue(viewModel.submissions.isEmpty)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.errorMessage)
        }
}
