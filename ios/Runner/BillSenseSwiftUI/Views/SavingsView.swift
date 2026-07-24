import SwiftUI
import Charts

public struct SavingsView: View {
    @EnvironmentObject private var billStore: BillStore
    
    public init() {}
    
    // Bar chart comparison points
    private var predictionBarData: [BarSavingsPoint] {
        let current = billStore.totalSpending
        let saving = billStore.totalEstimatedSavings
        
        return [
            BarSavingsPoint(period: "Now", amount: current, color: Theme.Colors.accentCoral),
            BarSavingsPoint(period: "1 Month", amount: max(0, current - (saving * 0.5)), color: Theme.Colors.accentAmber),
            BarSavingsPoint(period: "2 Months", amount: max(0, current - saving), color: Theme.Colors.accentEmerald)
        ]
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Banner Header Metric
                        GlassCard(strokeColor: Theme.Colors.accentEmerald.opacity(0.5)) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.Gradients.emeraldLinear)
                                        .frame(width: 54, height: 54)
                                        .shadow(color: Theme.Colors.accentEmerald.opacity(0.4), radius: 10, x: 0, y: 4)
                                    
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Estimated 2-Month Savings")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.textMuted)
                                    
                                    Text("₹\(Int(billStore.totalEstimatedSavings))")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.Colors.accentEmerald)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // MARK: - Bar Graph Future Savings Prediction (Swift Charts)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Future Saving Prediction")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text("Projected expense reduction by adopting AI tips")
                                        .font(.caption)
                                        .foregroundColor(Theme.Colors.textMuted)
                                }
                                
                                Chart(predictionBarData) { point in
                                    BarMark(
                                        x: .value("Period", point.period),
                                        y: .value("Amount", point.amount),
                                        width: .fixed(34)
                                    )
                                    .foregroundStyle(point.color)
                                    .cornerRadius(Theme.Layout.cornerRadiusSmall)
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisValueLabel {
                                            if let intVal = value.as(Int.self) {
                                                Text("₹\(intVal)")
                                                    .font(.caption2)
                                                    .foregroundColor(Theme.Colors.textMuted)
                                            }
                                        }
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                            .foregroundStyle(Theme.Colors.glassBorder)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel {
                                            if let strVal = value.as(String.self) {
                                                Text(strVal)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Theme.Colors.textSecondary)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 200)
                            }
                        }
                        
                        // MARK: - Category Budget Goals Progress Rings
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Monthly Category Budgets")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                ForEach(BillCategory.allCases) { category in
                                    let spent = billStore.categoryTotal(for: category)
                                    let limit = max(spent * 1.3, 3000)
                                    let progress = min(1.0, spent / limit)
                                    
                                    VStack(spacing: 8) {
                                        HStack {
                                            Image(systemName: category.iconName)
                                                .foregroundColor(category.color)
                                            Text(category.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Theme.Colors.textPrimary)
                                            Spacer()
                                            Text("₹\(Int(spent)) / ₹\(Int(limit))")
                                                .font(.caption)
                                                .foregroundColor(Theme.Colors.textSecondary)
                                        }
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.white.opacity(0.08))
                                                    .frame(height: 8)
                                                Capsule()
                                                    .fill(category.color)
                                                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(Theme.Layout.paddingStandard)
                }
            }
            .navigationTitle("Savings & Budgets")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BarSavingsPoint: Identifiable {
    var id: String { period }
    let period: String
    let amount: Double
    let color: Color
}

#Preview {
    SavingsView()
        .environmentObject(BillStore())
}
