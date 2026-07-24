import SwiftUI

public struct SignupView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Theme.Gradients.mainBackground
                .ignoresSafeArea()
            
            // Ambient Radial Glow
            Circle()
                .fill(Theme.Colors.accentPurple.opacity(0.2))
                .frame(width: 320, height: 320)
                .blur(radius: 50)
                .offset(x: 100, y: -160)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Navigation Header with Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Back")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Theme.Colors.accentIndigo)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color.white.opacity(0.06)))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Title Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.accentAmber)
                        }
                        
                        Text("Join BillSense to automate bill scanning & AI savings insights")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Form Container
                    GlassCard {
                        VStack(spacing: 16) {
                            if let error = authVM.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Theme.Colors.accentCoral)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(Theme.Colors.accentCoral)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Theme.Colors.accentCoral.opacity(0.15))
                                .cornerRadius(Theme.Layout.cornerRadiusSmall)
                            }
                            
                            GlassTextField(
                                placeholder: "Full Name",
                                text: $authVM.fullNameText,
                                iconName: "person.fill"
                            )
                            
                            GlassTextField(
                                placeholder: "Email Address",
                                text: $authVM.emailText,
                                iconName: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            GlassTextField(
                                placeholder: "Password",
                                text: $authVM.passwordText,
                                iconName: "lock.fill",
                                isSecure: true
                            )
                            
                            // Password Strength Bar
                            if !authVM.passwordText.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(authVM.passwordStrength.label)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(authVM.passwordStrength.color)
                                        Spacer()
                                    }
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(height: 5)
                                            Capsule()
                                                .fill(authVM.passwordStrength.color)
                                                .frame(width: geo.size.width * CGFloat(authVM.passwordStrength.progress), height: 5)
                                        }
                                    }
                                    .frame(height: 5)
                                }
                                .transition(.opacity)
                            }
                            
                            GlassTextField(
                                placeholder: "Confirm Password",
                                text: $authVM.confirmPasswordText,
                                iconName: "lock.shield.fill",
                                isSecure: true
                            )
                            
                            // Terms & Conditions Checkbox
                            Button(action: {
                                withAnimation { authVM.agreedToTerms.toggle() }
                            }) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: authVM.agreedToTerms ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18))
                                        .foregroundColor(authVM.agreedToTerms ? Theme.Colors.accentIndigo : Theme.Colors.textMuted)
                                    
                                    Text("I agree to the Terms of Service & Privacy Policy")
                                        .font(.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                            
                            // Primary Signup Button
                            Button(action: {
                                Task { await authVM.signup() }
                            }) {
                                ZStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        HStack(spacing: 8) {
                                            Text("Create Account")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            Image(systemName: "arrow.right")
                                                .font(.subheadline.bold())
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.Gradients.accentLinear)
                                .cornerRadius(Theme.Layout.cornerRadiusMedium)
                                .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 12, x: 0, y: 6)
                            }
                            .buttonStyle(InteractiveGlassCardStyle())
                            .disabled(authVM.isLoading)
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, Theme.Layout.paddingStandard)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
}
