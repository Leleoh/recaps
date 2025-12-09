//
//  ProfileViewModelProtocol.swift
//  recaps
//
//  Created by Ana Poletto on 02/12/25.
//

import Foundation

protocol ProfileViewModelProtocol {
    var user: User? { get }
    var userName: String { get }
    var userEmail: String { get }
    var allowNotifications: Bool { get }
    
    func logout()
    func loadUser() async
    func deleteAccount() async
}
