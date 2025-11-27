import SwiftUI

struct InputSubmissionView: View {
    
    @State private var selectedIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    let cards = [
        "monkey",
        "CloseCapsule",
        "verticalImage",
    ]
    
    @State private var messages: [String] = ["","",""]
    
    var onTapItem: ((Int) -> Void)? = nil
    
    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 240
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    VStack(spacing:5) {
                        // Dot indicator
                        HStack(spacing: 8) {
                            ForEach(0..<cards.count, id: \.self) { index in
                                Circle()
                                    .fill(selectedIndex == index ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 130)
                        
                        Spacer()
                        
                        ZStack {
                            ForEach(0..<cards.count, id: \.self) { index in
                                VStack(spacing: 40) {
                                    VStack {
                                        Image(cards[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: cardWidth, height: cardHeight)
                                            .rotationEffect(.degrees(-2))
                                        
                                        HStack {
                                                Spacer()
                                                Text("22/11/25")
                                                .font(.system(size: 18))
                                                .rotationEffect(.degrees(-2))
                                            }
                                            .frame(width: cardWidth)
                                            
                                    }
                                    
                                    TextField("Write a message \n (If you want)", text: $messages[index])
                                        .font(.system(size: 32))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                .onTapGesture {
                                    onTapItem?(index)
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
                                    
                                    newIndex = max(0, min(cards.count - 1, newIndex))
                                    
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        selectedIndex = newIndex
                                    }
                                }
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 343)
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
            .navigationTitle("Memory")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button() {
                        print("Confirmed with messages: \(messages)")
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.red)
                            
                           
                    }
                }
            }
        }
        
    }
}

#Preview {
    InputSubmissionView()
}
