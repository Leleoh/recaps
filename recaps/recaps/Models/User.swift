// MARK: - User

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var mail: String
    var capsulesIDs: [UUID]
    var photo: Data
}

// MARK: - Capsule

struct Capsule: Codable, Identifiable {
    let id: UUID
    var code: String
    var submissions: [Submission]
    var name: String
    var createdAt: Date
    var offensive: Int
    var lastSubmissionDate: Date
    var validOffensive: Bool
    var lives: Int
    var members: [UUID]
    var ownerId: UUID
    var status: CapsuleStatus
}
