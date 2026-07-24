import Foundation

/// AI Generated Expense Analysis Report Model
public struct AIReport: Identifiable, Codable {
    public let id: UUID
    public let billId: UUID
    public let amount: Double
    public let category: BillCategory
    public let insightText: String
    public let suggestionText: String
    public let predictedSavings: Double
    public let tips: [String]
    
    public init(
        id: UUID = UUID(),
        billId: UUID,
        amount: Double,
        category: BillCategory,
        insightText: String,
        suggestionText: String,
        predictedSavings: Double,
        tips: [String]
    ) {
        self.id = id
        self.billId = billId
        self.amount = amount
        self.category = category
        self.insightText = insightText
        self.suggestionText = suggestionText
        self.predictedSavings = predictedSavings
        self.tips = tips
    }
    
    public static func generateMockReport(for bill: Bill) -> AIReport {
        let saving = bill.amount * 0.22
        
        let insight: String
        let suggestion: String
        let tips: [String]
        
        switch bill.category {
        case .food:
            insight = "Dining & cafe expenses accounted for 35% of your recent spending. Peak spending occurred over the weekend."
            suggestion = "Subscribing to dining loyalty passes or cooking weekend meal plans could save up to ₹\(Int(saving)) monthly."
            tips = [
                "Utilize weekend promo discount coupons when dining out.",
                "Opt for combo packages or digital meal subscriptions.",
                "Track impulse coffee purchases to stay under budget."
            ]
        case .shopping:
            insight = "Retail shopping transactions show high non-essential purchases during seasonal sales."
            suggestion = "Applying a 48-hour cool-off rule before purchasing online items can optimize your wallet."
            tips = [
                "Compare prices on price-drop tracker extensions.",
                "Look out for cashback credit card promotions.",
                "Create a dedicated monthly shopping allowance budget."
            ]
        case .travel:
            insight = "Commute expenses are moderate. Frequent peak-hour ride requests slightly increased average fare."
            suggestion = "Scheduling rides 15 minutes before peak hours can cut ride-share costs by 18%."
            tips = [
                "Consider monthly transit passes or shared rides.",
                "Combine errands into single multi-stop trips.",
                "Utilize wallet cashback offers on transit top-ups."
            ]
        case .bills:
            insight = "Utility and fixed bill expenses are within normal range with slight variance in electricity consumption."
            suggestion = "Setting up auto-pay discounts can earn 2-5% rebates on recurring utility invoices."
            tips = [
                "Enroll in paperless billing discount programs.",
                "Use smart surge protectors for idle appliances.",
                "Pay invoices early to avoid late fee penalties."
            ]
        default:
            insight = "General spending shows consistent baseline activity across categories."
            suggestion = "Allocating 20% of general expense balances straight into automated savings yields solid growth."
            tips = [
                "Categorize uncategorized receipts regularly.",
                "Set weekly budget milestone notifications.",
                "Review subscription renewals monthly."
            ]
        }
        
        return AIReport(
            billId: bill.id,
            amount: bill.amount,
            category: bill.category,
            insightText: insight,
            suggestionText: suggestion,
            predictedSavings: saving,
            tips: tips
        )
    }
}
