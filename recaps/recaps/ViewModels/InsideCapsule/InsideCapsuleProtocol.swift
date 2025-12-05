//
//  InsideCapsuleProtocol.swift
//  recaps
//
//  Created by Fernando Sulzbach on 05/12/25.
//

import SwiftUI
import UIKit
import PhotosUI

protocol InsideCapsuleViewModelProtocol: AnyObject {

    var selectedImages: [UIImage] { get set }
    var selectedPickerItems: [PhotosPickerItem] { get set }
    var users: [User] { get set }
    var capsuleOwner: String { get set }
    var currentTime: Date { get set }

    func loadSelectedImages() async
    func reloadCapsule(id: UUID) async throws -> Capsule?
    func getUsers(IDs: [String], ownerID: String) async throws
    func setTime() async throws
}
