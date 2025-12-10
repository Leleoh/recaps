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

    let vm = PostOpenedCapsuleViewModel()
    
    // MARK: - Helpers
    
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
    func orderSubmission_sortsByDateDescending() async {
        let d1 = Date(timeIntervalSince1970: 1000)
        let d2 = Date(timeIntervalSince1970: 2000)
        let d3 = Date(timeIntervalSince1970: 3000)
        
        let submissions = [
            makeSubmission(date: d1),
            makeSubmission(date: d3),
            makeSubmission(date: d2)
        ]
        
        await MainActor.run {
            let result = vm.orderSubmission(submissions: submissions)
            #expect(result[0].date == d3)
            #expect(result[1].date == d2)
            #expect(result[2].date == d1)
        }
    }

    @Test
    func formatDate_returnsCorrectFormat() async {
        let date = Date(timeIntervalSince1970: 0)
        await MainActor.run {
            let formatted = vm.formatDate(date)
            #expect(formatted == "31/12/1969")
        }
    }

    @Test
    func dates_returnsRangeString() async {
        let first = makeSubmission(date: Date(timeIntervalSince1970: 0))
        let last  = makeSubmission(date: Date(timeIntervalSince1970: 86400))
        
        await MainActor.run {
            let result = vm.dates(submissions: [first, last])
            
            #expect(result == "31/12/1969 - 01/01/1970")
        }
    }

    @Test
    func dates_returnsEmptyStringWhenArrayIsEmpty() async {
        await MainActor.run {
            let result = vm.dates(submissions: [])
            #expect(result == "")
        }
    }

    @Test
    func groupedByMonthGroupsCorrectly() async {
        let jan = makeSubmission(date: Date(timeIntervalSince1970: 0))        // Jan
        let jan2 = makeSubmission(date: Date(timeIntervalSince1970: 86400))
        let feb = makeSubmission(date: Date(timeIntervalSince1970: 32 * 86400))
        
        await MainActor.run {
            let result = vm.groupedByMonth(submissions: [jan, jan2, feb])
            
            #expect(result.count == 3)
        }
    }

}
