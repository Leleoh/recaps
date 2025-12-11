//
//  ProfileViewModelTests.swift
//  recapsTests
//
//  Created by Ana Poletto on 02/12/25.
//

import Testing
import Foundation
@testable import recaps

struct ProfileViewModelTests {
    
    @Test func testLoadUser() async throws {
        let mockUser = User(id: "1", name: "teste", email: "ana@test.com", capsules: [], openCapsules: [])
        let userService = MockUserService()
        userService.mockCurrentUser = mockUser
        
        let viewModel = await ProfileViewModel(userService: userService)
        
        await viewModel.loadUser()
        
        #expect((viewModel.user != nil))
        await #expect(viewModel.user?.name == "teste")
        #expect(viewModel.userName == "teste")
        #expect(viewModel.userEmail == "ana@test.com")
        #expect(userService.didGetCurrentUser)
    }
    
    @Test func testLogout() async throws {
        let mockUser = User(id: "1", name: "Ana", email: "ana@test.com", capsules: [], openCapsules: [])
        let userService = MockUserService()
        userService.mockCurrentUser = mockUser
        
        let viewModel = await ProfileViewModel(userService: userService)
        await viewModel.loadUser()
        
        await viewModel.logout()
        
        #expect(viewModel.user == nil)
        #expect(userService.didLogout)
    }
    
    @Test func testRemoveUserFromAllCapsules() async throws {
        let capsuleID = UUID()
        let user = User(id: "user1", name: "Ana", email: "ana@test.com", capsules: [capsuleID], openCapsules: [])
        let capsule = Capsule(
            id: capsuleID,
            code: "teste",
            submissions: [],
            name: "MockCapsule",
            createdAt: Date(),
            offensive: 3,
            offensiveTarget: 30,
            lastSubmissionDate: Date(),
            validOffensive: false,
            lives: 3,
            members: ["user1"],
            ownerId: "owner1",
            status: .inProgress,
            blacklisted: []
        )
        
        let capsuleService = MockCapsuleService()
        let _ = try await capsuleService.createCapsule(capsule: capsule)
        
        let viewModel = await ProfileViewModel(capsuleService: capsuleService)
        await MainActor.run {
            viewModel.user = user
        }
        
        await viewModel.removeUserFromAllCapsules()
        
        // Verifica se o capsuleService realmente buscou a capsule
        #expect(capsuleService.didFetchCapsules)
        
        // Verifica se o usuário foi removido da capsule
        let updatedCapsules = try await capsuleService.fetchCapsules(IDs: [capsuleID])
        #expect(updatedCapsules.first?.members.contains("user1") == false)
    }
    
    @Test func testDeleteAccount() async throws {
        let capsuleID = UUID()
        let user = User(id: "user1", name: "Ana", email: "ana@test.com", capsules: [capsuleID], openCapsules: [])
        let capsule = Capsule(
            id: capsuleID,
            code: "teste",
            submissions: [],
            name: "MockCapsule",
            createdAt: Date(),
            offensive: 3,
            offensiveTarget: 30,
            lastSubmissionDate: Date(),
            validOffensive: false,
            lives: 3,
            members: ["user1"],
            ownerId: "owner1",
            status: .inProgress,
            blacklisted: []
        )
        
        let capsuleService = MockCapsuleService()
        _ = try await capsuleService.createCapsule(capsule: capsule)
        
        let userService = MockUserService()
        userService.mockCurrentUser = user
        
        let viewModel = await ProfileViewModel(capsuleService: capsuleService, userService: userService)
        await MainActor.run {
            viewModel.user = user
        }
        
        await viewModel.deleteAccount()
        
        #expect(userService.didDeleteUser)
        #expect(viewModel.user == nil)
        
        let updatedCapsules = try await capsuleService.fetchCapsules(IDs: [capsuleID])
        #expect(updatedCapsules.first?.members.contains("user1") == false)
    }
}
