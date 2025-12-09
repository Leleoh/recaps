import SwiftUI
import PhotosUI
import Lottie

struct InsideCapsule: View {
    
    @State var capsule: Capsule
    
    @State var capsuleMembers: [User] = []
    
    @State private var showInputComponent = false
    @State private var showMemberList = false
    
    @State private var goToInputView = false
    
    @State private var showCamera = false
    @State private var showGallery = false
    
    @State private var vm = InsideCapsuleViewModel()
    
    var body: some View {
        
        ZStack{
            if vm.goToGame{
                Color.black
                    .ignoresSafeArea()
            } else {
                ZStack {
                    ScrollView {
                        VStack(spacing: 34) {
                            
                            VStack(spacing: 62) {
                                NameComponent(text: .constant(capsule.name))
                                    .disabled(true)
                                
                                CloseCapsuleWithAnimation(
                                    capsule: capsule,
                                    onTap: {
                                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                                        impact.impactOccurred()
                                        Task{
                                            if await vm.canPlayGame(capsuleId: capsule.id) {
                                                vm.showFullScreenAnimation = true
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    vm.showFullScreenAnimation = false
                                                    vm.goToGame = true
                                                }
                                            } else {
                                                vm.isShaking = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    vm.isShaking = false
                                                    vm.showAlert = true
                                                }
                                            }
                                        }
                                        
                                    }
                                )
                                .rotationEffect(.degrees(vm.isShaking ? 5 : 0))
                                .animation(
                                    vm.isShaking ? .easeInOut(duration: 0.1).repeatCount(3, autoreverses: true) : .default,
                                    value: vm.isShaking
                                )
                            }
                            
                            Text("Click on Recapsule to take a look")
                                .font(.footnote)
                            //.foregroundStyle(Color("SweetnSour"))
                                .foregroundStyle(.secondary)
                            
                            VStack(spacing: 32) {
                                
                                VStack(spacing: 4) {
                                    HStack(spacing: 38) {
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Streak days")
                                                .font(.title2)
                                            
                                            Text("\(capsule.offensive) / \(capsule.offensiveTarget)")
                                                .font(.body)
                                                .foregroundStyle(.secondary)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Daily submission")
                                                    .font(.body)
                                                    .foregroundStyle(.secondary)
                                                
                                                if capsule.lastSubmissionDate.ddMMyyyy == vm.currentTime.ddMMyyyy {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(.secondary)
                                                        
                                                        Text("Done")
                                                            .font(.body)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                } else {
                                                    HStack {
                                                        Image(systemName: "clock.fill")
                                                            .foregroundStyle(.secondary)
                                                        
                                                        Text("Pending")
                                                            .font(.body)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                            }
                                        }
                                        .frame(width: 141, alignment: .leading)
                                        
                                        ActivityRing(capsule: capsule)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.quaternary)
                                            .opacity(0.8)
                                    )
                                    
                                    HStack {
                                        CapsuleLifes(capsule: capsule)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(.quaternary)
                                            .opacity(0.8)
                                    )
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Created by")
                                    Text(vm.capsuleOwner)
                                        .font(.coveredByYourGraceSignature)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 62)
                        
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        do {
                            if let reloaded = try await vm.reloadCapsule(id: capsule.id) {
                                capsule = reloaded
                            }
                        } catch {
                            print("Failed refresh:", error)
                        }
                    }
                    
                    if showInputComponent {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showInputComponent = false
                                }
                            }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 16) {
                                
                                if showInputComponent {
                                    SubmissionComponent(
                                        onButtonPhotograph: { showCamera = true },
                                        onButtonGallery: { showGallery = true }
                                    )
                                    .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 32))
                                    .padding(.horizontal, 24)
                                }
                                
                                InputSubmissionButton {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showInputComponent.toggle()
                                    }
                                }
                                .frame(width: 48, height: 48)
                                .padding(.trailing, 26)
                                .padding(.bottom, 48)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if vm.showPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    InvitePopUp(
                        isShowing: $vm.showPopup,
                        code: capsule.code
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .zIndex(2)
            }
            if vm.showFullScreenAnimation {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    LottieView(animation: .named("OpenGame"))
                        .playing(loopMode: .playOnce)
                        .configure {
                            $0.contentMode = .scaleAspectFill
                        }
                        .ignoresSafeArea()
                }
                .zIndex(10)
            }
            
        }
        
        .background {
            Image("backgroundImage")
                .resizable()
                .ignoresSafeArea()
        }
        
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.showPopup = true } label: {
                    Image(systemName: "link")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .primaryAction)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button { showMemberList = true } label: {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $vm.capturedImage, selectedItem: $vm.capturedPickerItem)
        }
        
        .sheet(isPresented: $showMemberList) {
            NavigationStack {
                MembersListView(members: $vm.users)
            }
        }
        
        .photosPicker(
            isPresented: $showGallery,
            selection: $vm.selectedPickerItems,
            maxSelectionCount: 5,
            matching: .images
        )
        
        .onChange(of: vm.selectedImages) { _, imgs in
            if !imgs.isEmpty {
                withAnimation { showInputComponent = false }
                goToInputView = true
            }
        }
        
        .onChange(of: vm.capturedImage) { _, newImage in
            if let image = newImage {
                vm.selectedImages = [image]
                vm.capturedImage = nil
            }
        }
        
        .navigationDestination(isPresented: $goToInputView) {
            InputSubmissionView(
                viewModel: InputSubmissionViewModel(images: vm.selectedImages, capsuleID: capsule.id)
            )
        }
        .fullScreenCover(isPresented: $vm.goToGame) {
            SlidingPuzzleView()
        }
        
        .onAppear {
            Task {
                try await vm.getUsers(IDs: capsule.members, ownerID: capsule.ownerId)
                try await vm.setTime()
            }
            vm.showFullScreenAnimation = false
        }
        
        .alert("Submission Needed", isPresented: $vm.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You need to submit today’s recap before you can play the game.")
        }
    }
}
