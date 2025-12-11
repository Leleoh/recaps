//
//  PhotoDetailsViewModelTests.swift
//  recapsTests
//
//  Created by Ana Poletto on 07/12/25.
//

import Testing
import UIKit
@testable import recaps

struct PhotoDetailsViewModelTests {
    @Test
    func testGetUser() async throws {
        let user = User(
            id: "1",
            name: "Ana",
            email: "ana@test.com",
            capsules: [],
            openCapsules: []
        )
        
        let mockUserService = MockUserService()
        mockUserService.mockFetchedUser = user
        
        let viewModel = await PhotoDetailsViewModel(
            userService: mockUserService
        )
        
        let name = await viewModel.getUser(id: "1")
        
        #expect(mockUserService.didGetUser)
        #expect(name == "Ana")
    }
    
    @Test
    func testFormatDate() async throws {
        let viewModel = await PhotoDetailsViewModel(
            userService: MockUserService()
        )
        
        var components = DateComponents()
        components.year = 2025
        components.month = 12
        components.day = 7
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!
        
        let formatted = await viewModel.formatDate(date)
        
        #expect(formatted == "07/12/2025")
    }
}
