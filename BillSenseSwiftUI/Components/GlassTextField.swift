import SwiftUI

/// Ultra-Premium Floating Glass Text Field Component
public struct GlassTextField: View {
    public let placeholder: String
    @Binding public var text: String
    public let iconName: String
    public var isSecure: Bool = false
    public var keyboardType: UIKeyboardType = .default
    
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool
    
    public init(
        placeholder: String,
        text: Binding<String>,
        iconName: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.iconName = iconName
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Theme.Colors.accentIndigo : Theme.Colors.textMuted)
                .frame(width: 24)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.textMuted)
                }
                
                if isSecure && !isPasswordVisible {
                    SecureField("", text: $text)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .focused($isFocused)
                } else {
                    TextField("", text: $text)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .focused($isFocused)
                }
            }
            
            if isSecure {
                Button(action: {
                    withAnimation { isPasswordVisible.toggle() }
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.textMuted)
                }
            } else if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.textMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                .fill(Color.white.opacity(isFocused ? 0.08 : 0.04))
                .background(
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                .stroke(
                    isFocused ? Theme.Colors.accentIndigo : Theme.Colors.glassBorder,
                    lineWidth: isFocused ? 1.5 : 1.0
                )
                .shadow(color: isFocused ? Theme.Colors.accentIndigo.opacity(0.4) : .clear, radius: 8, x: 0, y: 0)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    ZStack {
        Theme.Gradients.mainBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            GlassTextField(placeholder: "Email Address", text: .constant("user@example.com"), iconName: "envelope.fill")
            GlassTextField(placeholder: "Password", text: .constant("secret123"), iconName: "lock.fill", isSecure: true)
        }
        .padding()
    }
}
