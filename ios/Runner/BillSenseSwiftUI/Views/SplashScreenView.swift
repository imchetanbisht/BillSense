import SwiftUI

public struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0.0
    @State private var glowPulse: Bool = false
    @Binding public var isActive: Bool
    
    public init(isActive: Binding<Bool>) {
        self._isActive = isActive
    }
    
    public var body: some View {
        ZStack {
            Theme.Gradients.mainBackground
                .ignoresSafeArea()
            
            // Glowing Ambient Light Orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.Colors.accentIndigo.opacity(glowPulse ? 0.45 : 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(glowPulse ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)
            
            VStack(spacing: 24) {
                // App Logo Icon
                ZStack {
                    Circle()
                        .fill(Theme.Gradients.accentLinear)
                        .frame(width: 100, height: 100)
                        .shadow(color: Theme.Colors.accentIndigo.opacity(0.6), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "receipt.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("BillSense AI")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Smart Expense Analytics & OCR")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
        .onAppear {
            glowPulse = true
            withAnimation(.easeOut(duration: 1.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}
