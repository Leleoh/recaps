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
//            SlidingPuzzleView(inputImage: UIImage(imageLiteralResourceName: "monkey"))
            AuthenthicationView()
        }
    }
}
