import SwiftUI
import Charts

public struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    public let bill: Bill
    public let report: AIReport
    
    public init(bill: Bill, report: AIReport) {
        self.bill = bill
        self.report = report
    }
    
    // Prediction data points for Swift Charts
    private var chartData: [SavingsTrendPoint] {
        [
            SavingsTrendPoint(period: "Now", amount: bill.amount),
            SavingsTrendPoint(period: "1 Month", amount: max(0, bill.amount - (report.predictedSavings * 0.5))),
            SavingsTrendPoint(period: "2 Months", amount: max(0, bill.amount - report.predictedSavings))
        ]
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // MARK: - Receipt Image Header
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge)
                                .fill(LinearGradient(colors: [Color.indigo.opacity(0.3), Color.purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(height: 160)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "doc.plaintext.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.9))
                                        Text("Scanned Receipt Details")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge))
                        }
                        
                        // MARK: - Amount & Category Summary Card
                        GlassCard {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(bill.category.color.opacity(0.2))
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: bill.category.iconName)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(bill.category.color)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bill.vendorName)
                                        .font(.headline)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    Text(bill.category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(bill.category.color)
                                }
                                
                                Spacer()
                                
                                Text(bill.formattedAmount)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                        }
                        
                        // MARK: - AI Insight & Suggestion Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Theme.Colors.accentIndigo)
                                    Text("AI Expense Insight")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                
                                Text(report.insightText)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Divider()
                                    .background(Theme.Colors.glassBorder)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Theme.Colors.accentAmber)
                                    Text("Smart Suggestion")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                
                                Text(report.suggestionText)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // MARK: - Estimated Savings Card
                        GlassCard(strokeColor: Theme.Colors.accentEmerald.opacity(0.4)) {
                            HStack(spacing: 12) {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Theme.Colors.accentEmerald)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Estimated 2-Month Savings")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.Colors.textMuted)
                                    
                                    Text("₹\(Int(report.predictedSavings))")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.accentEmerald)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // MARK: - Swift Charts Spending Trend Line Chart
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Predicted Savings Curve")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Chart(chartData) { point in
                                    LineMark(
                                        x: .value("Period", point.period),
                                        y: .value("Amount", point.amount)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Theme.Gradients.emeraldLinear)
                                    .lineStyle(LineWidth(4))
                                    
                                    PointMark(
                                        x: .value("Period", point.period),
                                        y: .value("Amount", point.amount)
                                    )
                                    .foregroundStyle(Theme.Colors.accentEmerald)
                                    .symbolSize(60)
                                    
                                    AreaMark(
                                        x: .value("Period", point.period),
                                        y: .value("Amount", point.amount)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Theme.Colors.accentEmerald.opacity(0.3), Theme.Colors.accentEmerald.opacity(0.0)],
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
                                                    .font(.caption)
                                                    .foregroundColor(Theme.Colors.textSecondary)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 180)
                            }
                        }
                        
                        // Done Action Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.Gradients.accentLinear)
                                .cornerRadius(Theme.Layout.cornerRadiusMedium)
                        }
                        .padding(.top, 10)
                    }
                    .padding(Theme.Layout.paddingStandard)
                }
            }
            .navigationTitle("AI Expense Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.Colors.accentIndigo)
                }
            }
        }
    }
}

struct SavingsTrendPoint: Identifiable {
    var id: String { period }
    let period: String
    let amount: Double
}

#Preview {
    let bill = Bill.samples.first!
    ReportView(bill: bill, report: AIReport.generateMockReport(for: bill))
}
