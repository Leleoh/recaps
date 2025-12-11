//
//  InputSubmissionViewModelTest.swift
//  recapsTests
//
//  Created by Ana Poletto on 10/12/25.
//

import Testing
import UIKit
@testable import recaps

struct InputSubmissionViewModelTests {

    func makeVm() -> InputSubmissionViewModel {
        let images = [UIImage(), UIImage()]
        let capsuleId = UUID()
        return InputSubmissionViewModel(
            images: images,
            capsuleID: capsuleId
        )
    }
    
    // MARK: - Tests
    @Test
    func CreatesEmptyMessagesArrayWithSameCountAsImages() async {
        let vm = makeVm()
        
        #expect(vm.messages.count == vm.images.count)
        #expect(vm.messages.allSatisfy { $0 == "" })
    }
    
    @Test
    func submitDoesNotThrow() async throws {
        let vm = makeVm()
        
        await MainActor.run {
            vm.messages = ["Oi", "Teste"]
        }
        try await vm.submit()
        #expect(true)
    }
}
