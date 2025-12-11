//
//  PostOpenedCapsuleViewModelTest.swift
//  recapsTests
//
//  Created by Ana Poletto on 10/12/25.
//

import Testing
import Foundation
@testable import recaps

struct PostOpenedCapsuleViewModelTests {
    
    // MARK: - Helpers
    
    func makeCapsule() -> Capsule {
        Capsule(id: UUID(), code: "123", submissions: [], name: "teste", createdAt: Date(), offensive: 1, offensiveTarget: 1, lastSubmissionDate: Date(), validOffensive: true, lives: 3, members: ["1"], ownerId: "1", status: .inProgress, dailyGameDate: Date(), dailyGameSubmission: UUID(), blacklisted: [])
    }
    
    func makeSubmission(date: Date) -> Submission {
        Submission(
            id: UUID(),
            imageURL: nil,
            description: "",
            authorId: "1",
            date: date,
            capsuleID: UUID()
        )
    }
    
    // MARK: - Tests
    
    @Test
    func sortsByDateDescending() {
        let vm = PostOpenedCapsuleViewModel(capsule: makeCapsule())
        
        let d1 = Date(timeIntervalSince1970: 1000)
        let d2 = Date(timeIntervalSince1970: 2000)
        let d3 = Date(timeIntervalSince1970: 3000)
        
        let submissions = [
            makeSubmission(date: d1),
            makeSubmission(date: d3),
            makeSubmission(date: d2)
        ]
        
        let result = vm.orderSubmission(submissions: submissions)
        
        #expect(result[0].date == d3)
        #expect(result[1].date == d2)
        #expect(result[2].date == d1)
    }
    
    @Test
    func returnsCorrectFormat() {
        let vm = PostOpenedCapsuleViewModel(capsule: makeCapsule())
        
        let date = Date(timeIntervalSince1970: 0)
        
        let formatted = vm.formatDate(date)
        
        #expect(formatted == "31/12/1969")
    }
    
    @Test
    func returnsRangeString() {
        let vm = PostOpenedCapsuleViewModel(capsule: makeCapsule())
        
        let first = makeSubmission(date: Date(timeIntervalSince1970: 0))
        let last  = makeSubmission(date: Date(timeIntervalSince1970: 86400))
        
        let result = vm.dates(submissions: [first, last])
        
        #expect(result == "31/12/1969 - 01/01/1970")
    }
    
    @Test
    func returnsEmptyStringWhenArrayIsEmpty() {
        let vm = PostOpenedCapsuleViewModel(capsule: makeCapsule())
        
        let result = vm.dates(submissions: [])
        
        #expect(result == "")
    }
    
    @Test
    func groupedByMonth() {
        let vm = PostOpenedCapsuleViewModel(capsule: makeCapsule())
        
        let jan = makeSubmission(date: Date(timeIntervalSince1970: 0))
        let jan2 = makeSubmission(date: Date(timeIntervalSince1970: 86400))
        let feb = makeSubmission(date: Date(timeIntervalSince1970: 32 * 86400))
        
        let result = vm.groupedByMonth(submissions: [jan, jan2, feb])
        
        #expect(result.count == 3)
    }
    
    @Test
    func loadsAndSortsSubmissions() async throws {
        let service = MockCapsuleService()
        
        let capsuleID = UUID()
        let capsule = Capsule(
            id: capsuleID,
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
        
        service.storedCapsules[capsuleID] = capsule
        
        let older = Submission(
            id: UUID(),
            imageURL: nil,
            description: "",
            authorId: "1",
            date: Date(timeIntervalSince1970: 1000),
            capsuleID: capsuleID
        )
        
        let newer = Submission(
            id: UUID(),
            imageURL: nil,
            description: "",
            authorId: "1",
            date: Date(),
            capsuleID: capsuleID
        )
        
        service.addSubmission(older)
        service.addSubmission(newer)
        
        let vm = PostOpenedCapsuleViewModel(
            capsule: capsule,
            capsuleService: service
        )
        
        try await vm.fetchSubmissions()
 
        #expect(vm.isLoading == false)
        #expect(vm.submissions.count == 2)
        await #expect(vm.submissions.first?.date == newer.date)
        await #expect(vm.submissions.last?.date == older.date)
    }
    
    
}
