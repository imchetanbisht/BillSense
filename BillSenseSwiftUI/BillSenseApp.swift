import SwiftUI

@main
struct BillSenseApp: App {
    @State private var isSplashActive: Bool = true
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashActive {
                    SplashScreenView(isActive: $isSplashActive)
                        .transition(.opacity)
                } else if authVM.isAuthenticated {
                    MainTabView()
                        .environmentObject(authVM)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else {
                    LoginView()
                        .environmentObject(authVM)
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSplashActive)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authVM.isAuthenticated)
            .preferredColorScheme(.dark)
        }
    }
}
