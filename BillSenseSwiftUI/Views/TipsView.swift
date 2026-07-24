import SwiftUI
import Charts

public struct TipsView: View {
    @EnvironmentObject private var billStore: BillStore
    @State private var expandedBillId: UUID? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                if billStore.bills.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.slash")
                            .font(.system(size: 64))
                            .foregroundColor(Theme.Colors.textMuted)
                        
                        Text("No AI Tips Available")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text("Scan a bill first to unlock personalized saving tips.")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Smart Recommendation Cards")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.horizontal, 4)
                            
                            ForEach(billStore.bills) { bill in
                                let report = AIReport.generateMockReport(for: bill)
                                let isExpanded = expandedBillId == bill.id
                                
                                GlassCard(padding: 16) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        Button(action: {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                if isExpanded {
                                                    expandedBillId = nil
                                                } else {
                                                    expandedBillId = bill.id
                                                }
                                            }
                                        }) {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Theme.Colors.accentAmber.opacity(0.2))
                                                        .frame(width: 40, height: 40)
                                                    Image(systemName: "lightbulb.fill")
                                                        .foregroundColor(Theme.Colors.accentAmber)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(bill.vendorName)
                                                        .font(.headline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Theme.Colors.textPrimary)
                                                    
                                                    Text("\(bill.formattedAmount) • \(bill.category.rawValue)")
                                                        .font(.caption)
                                                        .foregroundColor(Theme.Colors.textSecondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Theme.Colors.textMuted)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if isExpanded {
                                            VStack(alignment: .leading, spacing: 16) {
                                                Divider()
                                                    .background(Theme.Colors.glassBorder)
                                                
                                                Text("Optimized Expense Breakdown")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Theme.Colors.textMuted)
                                                
                                                Chart {
                                                    SectorMark(
                                                        angle: .value("Amount", bill.amount),
                                                        innerRadius: .ratio(0.6),
                                                        angularInset: 25
                                                    )
                                                    .foregroundStyle(Theme.Colors.accentCoral)
                                                    
                                                    SectorMark(
                                                        angle: .value("Savings", report.predictedSavings),
                                                        innerRadius: .ratio(0.6),
                                                        angularInset: 25
                                                    )
                                                    .foregroundStyle(Theme.Colors.accentEmerald)
                                                    
                                                    SectorMark(
                                                        angle: .value("Optimized", max(0, bill.amount - report.predictedSavings)),
                                                        innerRadius: .ratio(0.6),
                                                        angularInset: 25
                                                    )
                                                    .foregroundStyle(Theme.Colors.accentIndigo)
                                                }
                                                .frame(height: 160)
                                                
                                                HStack(spacing: 16) {
                                                    LegendItem(color: Theme.Colors.accentCoral, label: "Spent: ₹\(Int(bill.amount))")
                                                    Spacer()
                                                    LegendItem(color: Theme.Colors.accentEmerald, label: "Save: ₹\(Int(report.predictedSavings))")
                                                    Spacer()
                                                    LegendItem(color: Theme.Colors.accentIndigo, label: "Target: ₹\(Int(max(0, bill.amount - report.predictedSavings)))")
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 10) {
                                                    ForEach(report.tips, id: \.self) { tip in
                                                        HStack(alignment: .top, spacing: 10) {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .foregroundColor(Theme.Colors.accentEmerald)
                                                                .font(.system(size: 16))
                                                            Text(tip)
                                                                .font(.caption)
                                                                .foregroundColor(Theme.Colors.textSecondary)
                                                        }
                                                    }
                                                }
                                            }
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 80)
                        }
                        .padding(Theme.Layout.paddingStandard)
                    }
                }
            }
            .navigationTitle("AI Smart Tips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10))
                .fontWeight(.semibold)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

#Preview {
    TipsView()
        .environmentObject(BillStore())
}
