//
//  DailyGameViewModel.swift
//  recaps
//
//  Created by Ana Poletto on 03/12/25.
//

import Foundation
class DailyGameViewModel {
    // MARK: Properties
    private let capsuleService = CapsuleService()
    
    func generateDailySubmission(capsule: Capsule) async throws -> Submission {
        let possibleSubmissions = try await capsuleService.fetchPossibleSubmissions(capsule: capsule)
        
        guard let dailySubmission = possibleSubmissions.first else {
            throw CapsuleError.noAvailableSubmissions
        }
        
        try await capsuleService.addSubmissionToBlacklist(
            capsule: capsule,
            submissionId: dailySubmission.id
        )
        
        return dailySubmission
    }

    enum CapsuleError: Error {
        case noAvailableSubmissions
    }
}
