//
//  HomeRecapsViewModel.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import Foundation

protocol HomeRecapsViewModelProtocol {
    var showCreateCapsule: Bool { get set }
    var showJoinPopup: Bool { get set }
    var showProfile: Bool { get set }
    var inProgressCapsules: [Capsule] { get }
    var completedCapsules: [Capsule] { get }
    
    func didTapNewRecap()
    func joinCapsule(code: String) async -> Capsule?
    func fetchCapsules() async
    func fetchCapsule(id: UUID) async -> Capsule?

    func leaveCapsule(capsule: Capsule) async
    func checkIfCapsuleIsValidOffensive(user: User) async
}
