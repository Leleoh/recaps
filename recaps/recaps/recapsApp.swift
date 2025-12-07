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
            let url = URL(string: "https://picsum.photos/300/200")!
            
            let testSubmissions = Submission(id: UUID(), imageURL: url, description: "Primeira", authorId: "1", date: Date(), capsuleID: UUID())
            PhotoDetailView(submission: testSubmissions)
        }
    }
}
