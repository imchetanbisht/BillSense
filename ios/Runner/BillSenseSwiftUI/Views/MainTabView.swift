import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var billStore = BillStore()
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Screen Switcher
            Group {
                switch selectedTab {
                case 0:
                    HomeView(selectedTab: $selectedTab)
                case 1:
                    InsightView()
                case 2:
                    SavingsView()
                case 3:
                    TipsView()
                case 4:
                    HistoryView()
                default:
                    HomeView(selectedTab: $selectedTab)
                }
            }
            .environmentObject(billStore)
            
            // Custom Floating Glass Bottom Navigation Bar
            HStack(spacing: 0) {
                TabItemButton(
                    title: "Home",
                    iconName: "house.fill",
                    isSelected: selectedTab == 0
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 0
                    }
                }
                
                TabItemButton(
                    title: "Insights",
                    iconName: "chart.xyaxis.line",
                    isSelected: selectedTab == 1
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 1
                    }
                }
                
                TabItemButton(
                    title: "Savings",
                    iconName: "leaf.fill",
                    isSelected: selectedTab == 2
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 2
                    }
                }
                
                TabItemButton(
                    title: "AI Tips",
                    iconName: "lightbulb.fill",
                    isSelected: selectedTab == 3
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 3
                    }
                }
                
                TabItemButton(
                    title: "History",
                    iconName: "clock.arrow.circlepath",
                    isSelected: selectedTab == 4
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = 4
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .background(
                        Capsule()
                            .fill(Theme.Colors.backgroundSecondary.opacity(0.85))
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Theme.Colors.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
            .padding(.horizontal, Theme.Layout.paddingStandard)
            .padding(.bottom, 14)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Tab Bar Button Component
struct TabItemButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Theme.Gradients.accentLinear)
                            .frame(width: 38, height: 38)
                            .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 6, x: 0, y: 3)
                    }
                    
                    Image(systemName: iconName)
                        .font(.system(size: isSelected ? 18 : 17, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Theme.Colors.textMuted)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Theme.Colors.accentIndigo : Theme.Colors.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}
