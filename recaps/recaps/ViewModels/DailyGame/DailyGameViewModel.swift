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
                
        let currentDate = try await capsuleService.fetchBrazilianTime().ddMMyyyy
        
        if capsule.dailyGameDate?.ddMMyyyy != currentDate {
            
            let possibleSubmissions = try await capsuleService
                .fetchPossibleSubmissions(capsule: capsule)
                .sorted { (lhs: Submission, rhs: Submission) in
                    lhs.id < rhs.id
                }
            
            guard let dailySubmission = possibleSubmissions.first else {
                throw CapsuleError.noAvailableSubmissions
            }
            
            try await capsuleService.addSubmissionToDailyGameAndBlacklist(
                capsule: capsule,
                submissionId: dailySubmission.id
            )
            
            return dailySubmission
            
        } else {
            if let dailyGameSubmissionID = capsule.dailyGameSubmission {
                if let currentDailySubmission = try await capsuleService.fetchSubmission(id: dailyGameSubmissionID) {
                    return currentDailySubmission
                } else {
                    throw CapsuleError.noAvailableSubmissions
                }
            } else {
                throw CapsuleError.noAvailableSubmissions
            }
        }
    }

    enum CapsuleError: Error {
        case noAvailableSubmissions
    }
}
