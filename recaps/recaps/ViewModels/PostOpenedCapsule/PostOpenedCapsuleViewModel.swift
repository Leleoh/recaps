//
//  PostOpenedCapsuleViewModel.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//
import Foundation

@Observable
class PostOpenedCapsuleViewModel {

    // MARK: - Ordenação
    func orderSubmission(submissions: [Submission]) -> [Submission] {
        submissions.sorted { $0.date > $1.date }
    }

    // MARK: - Datas
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

    // MARK: - Agrupar por mês
    func groupedByMonth(submissions: [Submission]) -> [String: [Submission]] {
        Dictionary(grouping: submissions) { submission in
            monthFormatter.string(from: submission.date)
        }
    }

    func sortedMonths(submissions: [Submission]) -> [String] {
        groupedByMonth(submissions: submissions)
            .keys
            .sorted(by: <)
            .map { $0 }
    }

    // MARK: - Formatter do mês
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "MMM"
        return f
    }()
}
