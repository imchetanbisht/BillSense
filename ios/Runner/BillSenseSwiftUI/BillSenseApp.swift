import SwiftUI

@main
struct BillSenseApp: App {
    @State private var isSplashActive: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashActive {
                    SplashScreenView(isActive: $isSplashActive)
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isSplashActive)
            .preferredColorScheme(.dark)
        }
    }
}
