import SwiftUI
import Combine

public enum PasswordStrength {
    case weak, medium, strong
    
    public var label: String {
        switch self {
        case .weak: return "Weak Password"
        case .medium: return "Good Password"
        case .strong: return "Strong Password"
        }
    }
    
    public var color: Color {
        switch self {
        case .weak: return Theme.Colors.accentCoral
        case .medium: return Theme.Colors.accentAmber
        case .strong: return Theme.Colors.accentEmerald
        }
    }
    
    public var progress: Double {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
}

@MainActor
public class AuthViewModel: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var emailText: String = ""
    @Published public var passwordText: String = ""
    @Published public var fullNameText: String = ""
    @Published public var confirmPasswordText: String = ""
    @Published public var agreedToTerms: Bool = false
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    public init() {}
    
    public var passwordStrength: PasswordStrength {
        let count = passwordText.count
        if count < 6 {
            return .weak
        } else if count < 10 {
            return .medium
        } else {
            return .strong
        }
    }
    
    public func login() async {
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate Auth Delay
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        isLoading = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isAuthenticated = true
        }
    }
    
    public func signup() async {
        guard !fullNameText.isEmpty, !emailText.isEmpty, !passwordText.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        guard passwordText == confirmPasswordText else {
            errorMessage = "Passwords do not match."
            return
        }
        guard agreedToTerms else {
            errorMessage = "Please accept the Terms & Conditions."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        isLoading = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isAuthenticated = true
        }
    }
    
    public func loginWithBiometrics() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isAuthenticated = true
        }
    }
    
    public func logout() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isAuthenticated = false
            emailText = ""
            passwordText = ""
        }
    }
}
