import SwiftUI
import CloudKit

struct CKUsabilityView: View {
    @State private var phrase: String = ""
    @State private var createdID = UUID()
    
    @State private var message: String = ""
    
    @State private var selectedCapsule: Capsule?
    
    @State private var capsules: [Capsule] = []
        
    private let CKService = CapsuleService()

    var body: some View {
        let mockId = UUID()

        let mockUser = User(
            id: "mock-user-id",
            name: "Leonel Hernandez",
            email: "leonel@example.com",
            capsules: [mockId]
        )
        let mockCapsule = Capsule(
            id: createdID,
            code: "A7K4Q",
            submissions: [],
            name: "Festa de Reveillon 2025",
            createdAt: Date(),
            offensive: 0,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress
        )
        let mockCapsuleUpdate = Capsule(
            id: createdID,
            code: "MORRALEONEL",
            submissions: [],
            name: "Festa de Reveillon 2025",
            createdAt: Date(),
            offensive: 0,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress
        )
        let mockSubmission = Submission(
            id: UUID(),
            imageURL: nil,
            description: "A vida é curta, vive cada momento!",
            authorId: mockUser.id,
            date: Date(),
            capsuleID: createdID
        )
        let idsToFetch: [UUID] = [
            UUID(uuidString: "116AF188-382F-4F93-8F4C-572E0015ADA1")
        ].compactMap { $0 }
        
        VStack(spacing: 20) {

            Button {
                Task {
                    do {
                        capsules = try await CKService.fetchAllCapsulesWithoutSubmissions()
                        print("Sucesso!")
                    } catch {
                        print("Erro ao buscar cápsulas: \(error)")
                    }
                }
            } label: {
                Text("Buscar Capsulas")
            }
            .buttonStyle(.borderedProminent)
    
            Button {
    
                Task {
                    do {
                        if let selectedCapsule = selectedCapsule {
                            try await CKService.updateLastSubmissionDate(capsuleID: selectedCapsule.id)
                            capsules = try await CKService.fetchAllCapsulesWithoutSubmissions()
                            print("Atualizado!")
                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao atualizar last submissiond a capsula: \(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Text("Atualizar Cápsula")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
    
                Task {
                    do {
                        if let selectedCapsule = selectedCapsule {
                            let validOffensive = try await CKService.checkIfCapsuleIsValidOffensive(capsuleID: selectedCapsule.id)
                            if !validOffensive {
                                let succeded = try await CKService.consumeCapsuleLive(capsuleID: selectedCapsule.id)
                                if succeded {
                                    capsules = try await CKService.fetchAllCapsulesWithoutSubmissions()
                                    print("Consumido com sucesso!")
                                } else {
                                    print("Não há vidas para consumir")
                                }
                            }
                            print("Capsula válida: \(validOffensive)")
                        }
                        
//                        await MainActor.run {
//                            message = "Capsula atualizada com sucesso! \n\(mockCapsule)"
//                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao atualizar last submissiond a capsula: \(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Text("Verificar se ValidOffensive é válido")
            }
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(capsules) { capsule in
                        
                        Button {
                            selectedCapsule = capsule
                        } label: {
                            HStack {
                                Text(capsule.id.uuidString)
                                Text(capsule.lastSubmissionDate, style: .date)
                                Text("\(capsule.lives)")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                selectedCapsule?.id == capsule.id
                                ? Color.blue.opacity(0.1)
                                : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.gray)
            }

            Spacer()
            
        }
        .padding()
    }

    // MARK: - Função CloudKit
    func savePhrase(_ phrase: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let container = CKContainer(identifier: "iCloud.com.Recaps.app")
        let database = container.publicCloudDatabase

        let record = CKRecord(recordType: "Phrase")
        record["text"] = phrase as CKRecordValue

        database.save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
