import SwiftUI
import CloudKit

struct CKUsabilityView: View {
    @State private var phrase: String = ""
    @State private var createdID = UUID()
    
    @State private var message: String = ""
    
    @State private var selectedCapsule: Capsule?
    
    @State private var capsules: [Capsule] = []
    
    @State private var submissions: [Submission] = []
    
    @State private var goToSubmissions: Bool = false
        
    private let CKService = CapsuleService()
    
    private static let dateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        let mockId = UUID()

        let mockUser = User(
            id: "mock-user-id",
            name: "Leonel Hernandez",
            email: "leonel@example.com",
            capsules: [mockId],
            openCapsules: []
        )
        let mockCapsule = Capsule(
            id: createdID,
            code: "A7K4Q",
            submissions: [],
            name: "Festa de Reveillon 2025",
            createdAt: Date(),
            offensive: 0,
            offensiveTarget: 50,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress,
            blacklisted: []
        )
        let mockCapsuleUpdate = Capsule(
            id: createdID,
            code: "MORRALEONEL",
            submissions: [],
            name: "Festa de Reveillon do Leonel 2025",
            createdAt: Date(),
            offensive: 0,
            offensiveTarget: 50,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress,
            blacklisted: []
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
        
        NavigationStack {
            VStack(spacing: 20) {
                
                Button {
                    Task {
                        do {
                            try await CKService.createCapsule(capsule: mockCapsule)
                            print("Sucesso!")
                        } catch {
                            print("Erro ao buscar cápsulas: \(error)")
                        }
                    }
                } label: {
                    Text("Criar Capsula")
                }
                .buttonStyle(.borderedProminent)

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
                                try await CKService.createSubmission(submission: mockSubmission, capsuleID: selectedCapsule.id, image: UIImage(named: "monkey") ?? UIImage())
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
                    Text("Enviar Submission para Cápsula")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
        
                    Task {
                        do {
                            if let selectedCapsule = selectedCapsule {
                                let validOffensive = try await CKService.checkIfCapsuleIsValidOffensive(capsuleID: selectedCapsule.id)
                                capsules = try await CKService.fetchAllCapsulesWithoutSubmissions()
                                
                                }

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
                
                Button {
        
                    Task {
                        do {
                            if let selectedCapsule = selectedCapsule {
                                let isCompleted = try await CKService.checkIfCapsuleIsCompleted(capsuleID: selectedCapsule.id)
                                if isCompleted {
                                    submissions = try await CKService.fetchSubmissions(capsuleID: selectedCapsule.id)
                                    goToSubmissions = true
                                } else {
                                    print("Capsula não esta completa seu burro")
                                }
                            }

                        } catch {
                            await MainActor.run {
                                message = "Erro ao atualizar last submissiond a capsula: \(error.localizedDescription)"
                            }
                        }
                    }
                } label: {
                    Text("Abrir Cápsula")
                }
                .buttonStyle(.borderedProminent)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(capsules) { capsule in
                            
                            Button {
                                selectedCapsule = capsule
                            } label: {
                                VStack (alignment: .leading) {
                                    Text(capsule.id.uuidString)
                                        .font(.system(size: 8, weight: .regular))
                                    
                                    HStack {
                                        Text("Streak: \(capsule.offensive)")
                                        Text(Self.dateTimeFormatter.string(from: capsule.lastSubmissionDate))
                                        Text("Status: \(capsule.status)")
                                    }
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
            .navigationDestination(isPresented: $goToSubmissions) {
                SubmissionsView(submissions: submissions)
            }
        }
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
