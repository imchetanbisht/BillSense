import SwiftUI

/// Reusable Glassmorphic Container View
public struct GlassCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let strokeColor: Color
    
    public init(
        cornerRadius: CGFloat = Theme.Layout.cornerRadiusLarge,
        padding: CGFloat = Theme.Layout.paddingStandard,
        strokeColor: Color = Theme.Colors.glassBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.strokeColor = strokeColor
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.Gradients.glassCard)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial.opacity(0.4))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 15, x: 0, y: 8)
    }
}

/// Interactive Glass Button Style with Spring Animation
public struct InteractiveGlassCardStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Theme.Gradients.mainBackground.ignoresSafeArea()
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Glassmorphic Card")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("Ultra-thin material with subtle stroke and shadow.")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding()
    }
}
