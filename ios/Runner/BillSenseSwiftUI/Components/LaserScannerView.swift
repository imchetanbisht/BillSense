import SwiftUI

/// Animated Neon Laser Line for OCR scanning overlay
public struct LaserScannerView: View {
    @State private var scanOffset: CGFloat = 0.0
    private let speed: Double
    
    public init(speed: Double = 2.5) {
        self.speed = speed
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Laser Beam Gradient Overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.0),
                                Color.green.opacity(0.25),
                                Color.green.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 40)
                    .offset(y: scanOffset * (geometry.size.height - 40))
                
                // High-intensity Glowing Line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color(red: 0.2, green: 1.0, blue: 0.6),
                                .white,
                                Color(red: 0.2, green: 1.0, blue: 0.6),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .shadow(color: Color(red: 0.2, green: 1.0, blue: 0.6), radius: 10, x: 0, y: 0)
                    .shadow(color: .green, radius: 4, x: 0, y: 0)
                    .offset(y: scanOffset * (geometry.size.height - 3))
            }
            .onAppear {
                withAnimation(
                    Animation.linear(duration: speed)
                        .repeatForever(autoreverses: true)
                ) {
                    scanOffset = 1.0
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 300, height: 200)
            .overlay(LaserScannerView())
    }
}
