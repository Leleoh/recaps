//
//  recapsApp.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 18/11/25.
//

import SwiftUI

@main
struct recapsApp: App {
    init() {
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 28, weight: .light)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            let calendar = Calendar.current
            let now = Date()
            let url1 = URL(string: "https://picsum.photos/300/400?random=1")!
            let url2 = URL(string: "https://picsum.photos/300/300?random=2")!
            let url3 = URL(string: "https://picsum.photos/300/300?random=3")!
            let url4 = URL(string: "https://picsum.photos/200/300?random=4")!
            let url5 = URL(string: "https://picsum.photos/300/300?random=5")!
            let url6 = URL(string: "https://picsum.photos/200/300?random=6")!
            let url7 = URL(string: "https://picsum.photos/300/200?random=7")!
            let url8 = URL(string: "https://picsum.photos/300/300?random=8")!
            let url9 = URL(string: "https://picsum.photos/300/200?random=9")!
            
            let s1 = Submission(id: UUID(), imageURL: url1, description: "Hoje", authorId: "1", date: now, capsuleID: UUID())
            let s2 = Submission(id: UUID(), imageURL: url2, description: "1 dia atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -1, to: now)!, capsuleID: UUID())
            let s3 = Submission(id: UUID(), imageURL: url3, description: "2 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -2, to: now)!, capsuleID: UUID())
            let s4 = Submission(id: UUID(), imageURL: url4, description: "3 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -23, to: now)!, capsuleID: UUID())
            let s5 = Submission(id: UUID(), imageURL: url5, description: "4 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -43, to: now)!, capsuleID: UUID())
            let s6 = Submission(id: UUID(), imageURL: url6, description: "5 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -22, to: now)!, capsuleID: UUID())
            let s7 = Submission(id: UUID(), imageURL: url7, description: "6 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -6, to: now)!, capsuleID: UUID())
            let s8 = Submission(id: UUID(), imageURL: url8, description: "7 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -7, to: now)!, capsuleID: UUID())
            let s9 = Submission(id: UUID(), imageURL: url9, description: "8 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -8, to: now)!, capsuleID: UUID())
            let s10 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -9, to: now)!, capsuleID: UUID())
            let s11 = Submission(id: UUID(), imageURL: url8, description: "7 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -7, to: now)!, capsuleID: UUID())
            let s12 = Submission(id: UUID(), imageURL: url9, description: "8 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -20, to: now)!, capsuleID: UUID())
            let s13 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -23, to: now)!, capsuleID: UUID())
            let s14 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -9, to: now)!, capsuleID: UUID())
            let s15 = Submission(id: UUID(), imageURL: url8, description: "7 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -7, to: now)!, capsuleID: UUID())
            let s16 = Submission(id: UUID(), imageURL: url9, description: "8 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -20, to: now)!, capsuleID: UUID())
            let s17 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -23, to: now)!, capsuleID: UUID())
            let s18 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -9, to: now)!, capsuleID: UUID())
            let s19 = Submission(id: UUID(), imageURL: url8, description: "7 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -7, to: now)!, capsuleID: UUID())
            let s20 = Submission(id: UUID(), imageURL: url9, description: "8 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -20, to: now)!, capsuleID: UUID())
            let s21 = Submission(id: UUID(), imageURL: url1, description: "9 dias atrás", authorId: "1", date: calendar.date(byAdding: .day, value: -23, to: now)!, capsuleID: UUID())
            
            
            let capsule = Capsule(
                id: UUID(),
                code: "F5GX3",
                submissions: [s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13],
                name: "Academy",
                createdAt: Date(),
                offensive: 2,
                offensiveTarget: 50,
                lastSubmissionDate: Date(),
                validOffensive: false,
                lives: 0,
                members: [],
                ownerId: " ",
                status: .inProgress
            )

            PostOpenedCapsuleView(capsule: capsule)
        }
    }
}
