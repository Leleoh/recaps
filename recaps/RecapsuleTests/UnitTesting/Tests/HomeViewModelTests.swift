//
//  HomeViewModelTests.swift
//  recapsTests
//
//  Created by Ana Poletto on 10/12/25.
//

import Testing
import Foundation
@testable import recaps

struct HomeRecapsViewModelTests {
    func makeCapsule(id: UUID) -> Capsule {
        Capsule(
            id: id,
            code: "123",
            submissions: [],
            name: "teste",
            createdAt: Date(),
            offensive: 1,
            offensiveTarget: 1,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: ["1"],
            ownerId: "1",
            status: .inProgress,
            dailyGameDate: Date(),
            dailyGameSubmission: UUID(),
            blacklisted: []
        )
    }

    func makeUser(progressIDs: [UUID], openIDs: [UUID]) -> User {
        User(
            id: "1",
            name: "Ana",
            email: "ana@test.com",
            capsules: progressIDs,
            openCapsules: openIDs
        )
    }

    // MARK: - Tests
    @MainActor
    @Test
    func fetchCapsules() async {
        let id1 = UUID()
        let id2 = UUID()
        let capsule1 = makeCapsule(id: id1)
        let capsule2 = makeCapsule(id: id2)

        let user = makeUser(progressIDs: [id1], openIDs: [id2])

        let capsuleService = MockCapsuleService()
        capsuleService.storedCapsules[id1] = capsule1
        capsuleService.storedCapsules[id2] = capsule2

        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        await vm.fetchCapsules()

        #expect(vm.fetchDone == true)
        #expect(vm.inProgressCapsules.count == 1)
        #expect(vm.completedCapsules.count == 1)
    }


    @Test
    func isLoading() {

        _ = makeUser(progressIDs: [], openIDs: [])
        let capsuleService = MockCapsuleService()
        let userService = MockUserService()

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        #expect(vm.isLoading == true)
    }

    @Test
    func didTapNewRecap() {

        _ = makeUser(progressIDs: [], openIDs: [])
        let capsuleService = MockCapsuleService()
        let userService = MockUserService()

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        vm.didTapNewRecap()

        #expect(vm.showCreateCapsule == true)
    }
    
    @MainActor
    @Test
    func refreshCapsules() async {
        let id1 = UUID()
        let id2 = UUID()
        let capsule1 = makeCapsule(id: id1)
        let capsule2 = makeCapsule(id: id2)

        let user = makeUser(progressIDs: [id1], openIDs: [id2])

        let capsuleService = MockCapsuleService()
        capsuleService.storedCapsules[id1] = capsule1
        capsuleService.storedCapsules[id2] = capsule2

        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )
        vm.user = user

        await vm.refreshCapsules()

        #expect(vm.inProgressCapsules.count == 1)
        #expect(vm.completedCapsules.count == 1)
        #expect(vm.inProgressCapsules.first?.id == id1)
        #expect(vm.completedCapsules.first?.id == id2)
    }
    
    @MainActor
    @Test
    func joinCapsuleSuccess() async {
        let capsuleID = UUID()
        let code = "ABC123"

        var capsule = makeCapsule(id: capsuleID)
        capsule.code = code
        capsule.members = []

        let user = makeUser(progressIDs: [], openIDs: [])

        let capsuleService = MockCapsuleService()
        capsuleService.storedCapsules[capsuleID] = capsule

        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        let result = await vm.joinCapsule(code: code)

        #expect(result != nil)
        #expect(vm.joinErrorMessage == nil)
    }

    @MainActor
    @Test
    func joinCapsuleError() async {
        let capsuleID = UUID()
        let code = "CODE123"

        var capsule = makeCapsule(id: capsuleID)
        capsule.code = code
        let user = makeUser( progressIDs: [], openIDs: [])
        
        capsule.members = [user.id]

        let capsuleService = MockCapsuleService()
        capsuleService.storedCapsules[capsuleID] = capsule

        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        let result = await vm.joinCapsule(code: code)

        #expect(result == nil)
        #expect(vm.joinErrorMessage == "AlreadyMember")
    }

    @MainActor
    @Test
    func leaveCapsule() async {
        let capsuleID = UUID()
        var capsule = makeCapsule(id: capsuleID)
        let user = makeUser(progressIDs: [capsuleID], openIDs: [])
        capsule.members = [user.id]

        let capsuleService = MockCapsuleService()
        capsuleService.storedCapsules[capsuleID] = capsule

        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )

        await vm.leaveCapsule(capsule: capsule)

        let updatedCapsule = capsuleService.storedCapsules[capsuleID]
        let updatedUser = userService.mockCurrentUser

        #expect(updatedCapsule?.members.contains(user.id) == false)
        #expect(updatedUser?.capsules.contains(capsuleID) == false)
    }

    @Test @MainActor
    func updateUserTest() async throws {
        let capsuleService = MockCapsuleService()
        let userService = MockUserService()

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )
        try await vm.updateUserTest()
        #expect(userService.didUpdateUser == true)
    }

    @Test @MainActor
    func changeCompletedCapsuleToOpenCapsule() async throws {
        let capsuleID = UUID()
        let user = User(
            id: "1",
            name: "Ana",
            email: "ana@test.com",
            capsules: [capsuleID],
            openCapsules: []
        )

        let capsuleService = MockCapsuleService()
        let userService = MockUserService()
        userService.mockCurrentUser = user

        let vm = HomeRecapsViewModel(
            capsuleService: capsuleService,
            userService: userService
        )
        
        vm.user = user
        try await vm.changeCompletedCapsuleToOpenCapsule(capsuleID: capsuleID)

        let updatedUser = userService.mockCurrentUser

        #expect(updatedUser?.capsules.contains(capsuleID) == false)
        #expect(updatedUser?.openCapsules.contains(capsuleID) == true)
    }
}
