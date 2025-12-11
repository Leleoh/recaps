//
//  InputSubmissionView.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 24/11/25.
//

import SwiftUI

struct InputSubmissionView: View {
    
    @State var viewModel: InputSubmissionViewModelProtocol
    
    @State private var selectedIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    @State private var isSubmitting = false
    @Environment(\.dismiss) var dismiss
    
    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 244
    
    init(viewModel: InputSubmissionViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    VStack(spacing:5) {
                        
                        // Dot indicator
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.images.count, id: \.self) { index in
                                Circle()
                                    .fill(selectedIndex == index ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 100)
                        
                        Spacer()
                        
                        ZStack {
                            ForEach(0..<viewModel.images.count, id: \.self) { index in
                                VStack(spacing: 0) {
                                    VStack {
                                        Image(uiImage: viewModel.images[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: cardWidth, height: cardHeight)
                                            .rotationEffect(.degrees(-2))
                                        
                                        HStack {
                                            Spacer()
                                            Text(Date.now.formatted(date: .numeric, time: .omitted))
                                                .font(.coveredByYourGraceSignature)
                                                .rotationEffect(.degrees(-2))
                                        }
                                        .frame(width: cardWidth)
                                    }
                                    
                                    TextField("Write a message", text: $viewModel.messages[index], axis: .vertical)
                                        .font(.coveredByYourGraceTitle)
                                        .lineLimit(2)
                                        .frame(maxWidth: 300)
                                        .frame(height: 108)
                                        .padding(8)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)

                                }
                                .offset(
                                    x: (CGFloat(index - selectedIndex) * (cardWidth + 30)) + dragOffset,
                                    y: 0
                                )
                            }
                        }
                        .frame(width: geometry.size.width)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 56
                                    var newIndex = selectedIndex
                                    
                                    if value.translation.width < -threshold {
                                        newIndex += 1
                                    } else if value.translation.width > threshold {
                                        newIndex -= 1
                                    }
                                    
                                    newIndex = max(0, min(viewModel.images.count - 1, newIndex))
                                    
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        selectedIndex = newIndex
                                    }
                                }
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 403)
                }
            }
            .padding(.top, 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(
                Image("backgroundImage")
                    .resizable()
                    .ignoresSafeArea()
            )
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                        Text("Memory")
                        .font(.system(size: 28, weight: .light))
                    }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
                
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSubmitting = true
                            do {
                                try await viewModel.submit()
                                dismiss()
                            } catch {
                                print("Erro ao enviar: \(error)")
                            }
                            isSubmitting = false
                        }
                    } label: {
                        Group {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .disabled(isSubmitting)
                    .buttonStyle(.borderedProminent)
                }
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
            .gesture(
                DragGesture().onChanged { value in
                    if value.translation.height > 20 {
                        UIApplication.shared.dismissKeyboard()
                    }
                }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
   // InputSubmissionView()
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
