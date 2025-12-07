//
//  AuthenthicationViewModelProtocol.swift
//  recaps
//
//  Created by Ana Poletto on 01/12/25.
//

import AuthenticationServices

protocol AuthenticationViewModelProtocol: AnyObject {
    var isSignedIn: Bool { get }
    
    @MainActor
    func handleAuthResult(_ result: Result<ASAuthorization, Error>) async
}
