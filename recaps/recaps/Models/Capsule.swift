//
//  Capsule.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//
import Foundation

// MARK: - Capsule

struct Capsule: Codable, Identifiable {
    let id: UUID
    var code: String
    var submissions: [Submission]
    var name: String
    var createdAt: Date
    var offensive: Int
    var offensiveTarget: Int
    var lastSubmissionDate: Date
    var validOffensive: Bool
    var lives: Int
    var members: [String]
    var ownerId: String
    var status: CapsuleStatus
    var dailyGameDate: Date?
    var dailyGameSubmission: UUID?
    var blacklisted: [UUID]
}
