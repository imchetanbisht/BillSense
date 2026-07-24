import SwiftUI

/// Animated Statistic metric summary card
public struct StatCard: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let iconName: String
    public let accentColor: Color
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconName: String,
        accentColor: Color = Theme.Colors.accentIndigo
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.accentColor = accentColor
    }
    
    public var body: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.18))
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.textMuted)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.Gradients.mainBackground.ignoresSafeArea()
        HStack(spacing: 16) {
            StatCard(title: "Total Spent", value: "₹14,250", subtitle: "+12% this month", iconName: "wallet.pass.fill", accentColor: Theme.Colors.accentIndigo)
            StatCard(title: "AI Savings", value: "₹3,400", subtitle: "25% optimized", iconName: "sparkles", accentColor: Theme.Colors.accentEmerald)
        }
        .padding()
    }
}
