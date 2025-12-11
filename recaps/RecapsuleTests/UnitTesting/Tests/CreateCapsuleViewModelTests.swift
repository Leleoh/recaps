//
//  CreateCapsuleViewModelTests.swift
//  recapsTests
//
//  Created by Ana Poletto on 10/12/25.
//

import Testing
import UIKit
@testable import recaps

struct CreateCapsuleViewModelTests {
    
    // MARK: - Helpers
    func services(
        capsuleService: MockCapsuleService = MockCapsuleService(),
        userService: MockUserService = MockUserService()
    ) -> CreateCapsuleViewModel {
        return CreateCapsuleViewModel(
            capsuleService: capsuleService,
            userService: userService
        )
    }
    
    // MARK: - Tests
    
    @Test
    func isValidToSaveWhenNoNameAndNoImagesReturnsFalse() async {
        let mockViewModel = services()
        
        await MainActor.run {
            mockViewModel.capsuleName = ""
            mockViewModel.selectedImages = []
        }
        
        #expect(mockViewModel.isValidToSave == false)
    }
    
    @Test
    func isValidToSaveWhenNameAndLessThan3ImagesReturnsFalse() async {
        let mockViewModel = services()
        
        await MainActor.run {
            mockViewModel.capsuleName = "My Capsule"
            mockViewModel.selectedImages = [UIImage(), UIImage()]
        }
        
        #expect(mockViewModel.isValidToSave == false)
    }
    
    @Test
    func isValidToSaveWhenNameAndThreeImagesReturnsTrue() async {
        let mockViewModel = services()
        
        await MainActor.run {
            mockViewModel.capsuleName = "My Capsule"
            mockViewModel.selectedImages = [UIImage(), UIImage(), UIImage()]
        }
        
        #expect(mockViewModel.isValidToSave == true)
    }
    
    @Test
    func createCapsuleWhenUserNotLoggedReturnsFalseAndSetsError() async throws {
        let capsuleService = MockCapsuleService()
        let userService = MockUserService()
        
        let mockViewModel = self.services(capsuleService: capsuleService, userService: userService)
        await MainActor.run {
            userService.userId = ""
            mockViewModel.capsuleName = "Test Capsule"
            mockViewModel.selectedImages = [UIImage(), UIImage(), UIImage()]
        }
        let result = await mockViewModel.createCapsule(code: "ABCDE")
        
        #expect(result == false)
        #expect(mockViewModel.errorMessage != nil)
        #expect(mockViewModel.isLoading == false)
    }
    
    @Test
    func createCapsuleWhenValidInputCreatesCapsuleAndUpdatesUser() async throws {
        let capsuleService = MockCapsuleService()
        let userService = MockUserService()
        
        let mockUser = User(
            id: "mock-user",
            name: "Ana",
            email: "ana@test.com",
            capsules: [],
            openCapsules: []
        )
        
        userService.mockCurrentUser = mockUser
        
        let mockViewModel = services(
            capsuleService: capsuleService,
            userService: userService
        )
        
        await MainActor.run {
            userService.userId = mockUser.id
            mockViewModel.capsuleName = "Capsule OK"
            mockViewModel.selectedImages = [UIImage(), UIImage(), UIImage()]
        }
        
        let result = await mockViewModel.createCapsule(code: "ABCDE")
        
        #expect(result == true)
        #expect(capsuleService.didCreateCapsuleWithSubmissions == true)
        #expect(userService.didUpdateUser == true)
        #expect(mockViewModel.errorMessage == nil)
        #expect(mockViewModel.isLoading == false)
    }
    
    @Test
    func CreateCode(){
        let mockViewModel = services()
        let code = mockViewModel.generateCode()
        
        #expect(code != "")
    }
}
