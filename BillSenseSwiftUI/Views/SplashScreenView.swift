import SwiftUI

public struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var glowMeshPulse: Bool = false
    @Binding public var isActive: Bool
    
    public init(isActive: Binding<Bool>) {
        self._isActive = isActive
    }
    
    public var body: some View {
        ZStack {
            Theme.Gradients.mainBackground
                .ignoresSafeArea()
            
            // MARK: - Ambient Multi-Layer Radial Glow Mesh
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.Colors.accentIndigo.opacity(glowMeshPulse ? 0.5 : 0.2), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 220
                        )
                    )
                    .frame(width: 380, height: 380)
                    .offset(x: glowMeshPulse ? -40 : 40, y: glowMeshPulse ? -60 : 60)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.Colors.accentCyan.opacity(glowMeshPulse ? 0.4 : 0.15), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(x: glowMeshPulse ? 60 : -60, y: glowMeshPulse ? 40 : -40)
            }
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: glowMeshPulse)
            
            // MARK: - Hero Logo Assembly & Title Typography
            VStack(spacing: 28) {
                ZStack {
                    // Outer Backdrop Halo Ring
                    Circle()
                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(glowMeshPulse ? 1.15 : 0.95)
                        .opacity(0.6)
                    
                    // Core Gradient Badge
                    Circle()
                        .fill(Theme.Gradients.accentLinear)
                        .frame(width: 110, height: 110)
                        .shadow(color: Theme.Colors.accentIndigo.opacity(0.7), radius: 25, x: 0, y: 12)
                    
                    Image(systemName: "receipt.fill")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                VStack(spacing: 10) {
                    Text("BillSense AI")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 10, x: 0, y: 4)
                    
                    Text("Smart Expense Analytics & OCR Scanner")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .offset(y: textOffset)
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            glowMeshPulse = true
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
                textOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}
