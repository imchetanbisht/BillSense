import SwiftUI

/// BillSense Design System - Modern Glassmorphic Dark Mode Tokens
public enum Theme {
    
    // MARK: - Colors
    public enum Colors {
        public static let backgroundPrimary = Color(red: 0.043, green: 0.071, blue: 0.125) // #0B1220
        public static let backgroundSecondary = Color(red: 0.059, green: 0.090, blue: 0.165) // #0F172A
        public static let backgroundDark = Color(red: 0.008, green: 0.024, blue: 0.090) // #020617
        
        public static let accentIndigo = Color(red: 0.388, green: 0.400, blue: 0.945) // #6366F1
        public static let accentPurple = Color(red: 0.545, green: 0.361, blue: 0.965) // #8B5CF6
        public static let accentEmerald = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981
        public static let accentCoral = Color(red: 0.937, green: 0.267, blue: 0.267) // #EF4444
        public static let accentAmber = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B
        public static let accentCyan = Color(red: 0.024, green: 0.714, blue: 0.831) // #06B6D4
        
        public static let textPrimary = Color.white
        public static let textSecondary = Color.white.opacity(0.7)
        public static let textMuted = Color.white.opacity(0.45)
        
        public static let glassBorder = Color.white.opacity(0.12)
        public static let glassHighlight = Color.white.opacity(0.08)
    }
    
    // MARK: - Gradients
    public enum Gradients {
        public static let mainBackground = LinearGradient(
            colors: [Colors.backgroundSecondary, Colors.backgroundDark],
            startPoint: .top,
            endPoint: .bottom
        )
        
        public static let accentLinear = LinearGradient(
            colors: [Colors.accentIndigo, Colors.accentPurple],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        public static let emeraldLinear = LinearGradient(
            colors: [Colors.accentEmerald, Color(red: 0.20, green: 0.85, blue: 0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let glassCard = LinearGradient(
            colors: [
                Color.white.opacity(0.08),
                Color.white.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let laserScan = LinearGradient(
            colors: [.clear, Color.green.opacity(0.8), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Layout
    public enum Layout {
        public static let cornerRadiusLarge: CGFloat = 24
        public static let cornerRadiusMedium: CGFloat = 16
        public static let cornerRadiusSmall: CGFloat = 12
        
        public static let paddingStandard: CGFloat = 20
        public static let paddingCompact: CGFloat = 12
    }
}
