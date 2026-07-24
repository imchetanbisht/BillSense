import SwiftUI
import Charts

public struct InsightView: View {
    @EnvironmentObject private var billStore: BillStore
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Metric Cards Summary Header
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Total Spending",
                                value: "₹\(Int(billStore.totalSpending))",
                                iconName: "wallet.pass.fill",
                                accentColor: Theme.Colors.accentIndigo
                            )
                            
                            StatCard(
                                title: "Total Bills",
                                value: "\(billStore.bills.count)",
                                iconName: "doc.text.fill",
                                accentColor: Theme.Colors.accentPurple
                            )
                            
                            StatCard(
                                title: "Average Bill",
                                value: "₹\(Int(billStore.averageSpending))",
                                iconName: "chart.bar.fill",
                                accentColor: Theme.Colors.accentCyan
                            )
                        }
                        
                        // MARK: - Spending Trend Line & Area Chart (Swift Charts)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Spending Overview")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        
                                        Text("Historical scan trajectory")
                                            .font(.caption)
                                            .foregroundColor(Theme.Colors.textMuted)
                                    }
                                    Spacer()
                                }
                                
                                Chart(billStore.bills.reversed()) { bill in
                                    LineMark(
                                        x: .value("Date", bill.formattedDate),
                                        y: .value("Amount", bill.amount)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Theme.Gradients.accentLinear)
                                    .lineStyle(LineWidth(3.5))
                                    
                                    PointMark(
                                        x: .value("Date", bill.formattedDate),
                                        y: .value("Amount", bill.amount)
                                    )
                                    .foregroundStyle(Theme.Colors.accentIndigo)
                                    .symbolSize(50)
                                    
                                    AreaMark(
                                        x: .value("Date", bill.formattedDate),
                                        y: .value("Amount", bill.amount)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Theme.Colors.accentIndigo.opacity(0.35), Theme.Colors.accentIndigo.opacity(0.0)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
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
                                                    .font(.system(size: 9))
                                                    .foregroundColor(Theme.Colors.textMuted)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 200)
                            }
                        }
                        
                        // MARK: - Category Breakdown Pie/Donut Chart
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Category Distribution")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Chart(BillCategory.allCases) { category in
                                    let categorySum = billStore.categoryTotal(for: category)
                                    if categorySum > 0 {
                                        SectorMark(
                                            angle: .value("Spending", categorySum),
                                            innerRadius: .ratio(0.55),
                                            angularInset: 2
                                        )
                                        .cornerRadius(6)
                                        .foregroundStyle(category.color)
                                    }
                                }
                                .frame(height: 200)
                                
                                // Legend Row
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(BillCategory.allCases) { category in
                                        let sum = billStore.categoryTotal(for: category)
                                        if sum > 0 {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(category.color)
                                                    .frame(width: 10, height: 10)
                                                Text(category.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(Theme.Colors.textSecondary)
                                                Spacer()
                                                Text("₹\(Int(sum))")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Theme.Colors.textPrimary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(Theme.Layout.paddingStandard)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    InsightView()
        .environmentObject(BillStore())
}
