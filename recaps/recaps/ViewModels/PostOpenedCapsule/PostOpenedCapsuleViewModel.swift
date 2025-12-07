//
//  PostOpenedCapsuleViewModel.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import Foundation

@Observable
class PostOpenedCapsuleViewModel {

    func orderSubmission(submissions: [Submission]) -> [Submission] {
        return submissions.sorted {
            $0.date > $1.date
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    func dates(submissions: [Submission]) -> String {
        guard let first = submissions.first,
              let last = submissions.last else {
            return ""
        }

        return "\(formatDate(first.date)) - \(formatDate(last.date))"
    }
}
