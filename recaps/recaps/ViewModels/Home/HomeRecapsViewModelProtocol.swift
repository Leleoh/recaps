//
//  HomeRecapsViewModel.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import Foundation

protocol HomeRecapsViewModelProtocol {
    var showCreateCapsule: Bool { get set }
    
    func didTapNewRecap()
    func joinCapsule(code: String) async
}
