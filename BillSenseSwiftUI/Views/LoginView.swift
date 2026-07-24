import SwiftUI

public struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showSignup: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                // Ambient Radial Glow
                Circle()
                    .fill(Theme.Colors.accentIndigo.opacity(0.25))
                    .frame(width: 340, height: 340)
                    .blur(radius: 50)
                    .offset(x: -100, y: -180)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // MARK: - Header Branding
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.Gradients.accentLinear)
                                    .frame(width: 76, height: 76)
                                    .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 15, x: 0, y: 8)
                                
                                Image(systemName: "receipt.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 20)
                            
                            VStack(spacing: 6) {
                                Text("Welcome Back")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("Sign in to continue tracking expenses with BillSense AI")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // MARK: - Glass Form Container
                        GlassCard {
                            VStack(spacing: 18) {
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
                                
                                HStack {
                                    Spacer()
                                    Button(action: {}) {
                                        Text("Forgot Password?")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Theme.Colors.accentIndigo)
                                    }
                                }
                                
                                // Primary Sign In Button
                                Button(action: {
                                    Task { await authVM.login() }
                                }) {
                                    ZStack {
                                        if authVM.isLoading {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            HStack(spacing: 8) {
                                                Text("Sign In to BillSense")
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
                        
                        // MARK: - Face ID Biometric Action
                        Button(action: {
                            Task { await authVM.loginWithBiometrics() }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 22))
                                Text("Sign in with Face ID")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Theme.Colors.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(Capsule().stroke(Theme.Colors.glassBorder, lineWidth: 1))
                            )
                        }
                        .buttonStyle(InteractiveGlassCardStyle())
                        
                        // MARK: - Social Connect Divider & Buttons
                        VStack(spacing: 16) {
                            HStack(spacing: 14) {
                                Rectangle().fill(Theme.Colors.glassBorder).frame(height: 1)
                                Text("Or connect with")
                                    .font(.caption)
                                    .foregroundColor(Theme.Colors.textMuted)
                                Rectangle().fill(Theme.Colors.glassBorder).frame(height: 1)
                            }
                            
                            HStack(spacing: 14) {
                                SocialPillButton(iconName: "apple.logo", title: "Apple ID") {
                                    Task { await authVM.loginWithBiometrics() }
                                }
                                SocialPillButton(iconName: "g.circle.fill", title: "Google") {
                                    Task { await authVM.loginWithBiometrics() }
                                }
                            }
                        }
                        
                        // MARK: - Switch to Signup Link
                        NavigationLink(destination: SignupView().environmentObject(authVM), isActive: $showSignup) {
                            HStack(spacing: 6) {
                                Text("Don't have an account?")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.accentIndigo)
                            }
                            .font(.subheadline)
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(.horizontal, Theme.Layout.paddingStandard)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SocialPillButton: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                    .stroke(Theme.Colors.glassBorder, lineWidth: 1)
            )
        }
        .buttonStyle(InteractiveGlassCardStyle())
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
