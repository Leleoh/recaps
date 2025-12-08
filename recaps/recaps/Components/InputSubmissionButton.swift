import SwiftUI

struct LiquidGlassButton: View {
    
    var action: () -> Void = { }
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.15, blue: 0.15),
                                Color(red: 0.45, green: 0, blue: 0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.9),
                                        Color.red.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.6
                            )
                    )
                    .shadow(color: Color.red.opacity(0.45), radius: 8, x: 0, y: 4)

                Circle()
                    .stroke(
                        RadialGradient(
                            colors: [
                                Color.red.opacity(0.75),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 40
                        ),
                        lineWidth: 10
                    )
                    .blur(radius: 4)

                // MARK: - Ícone
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LiquidGlassButton()
}
