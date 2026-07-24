import SwiftUI

/// Bill Category Types
public enum BillCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food"
    case shopping = "Shopping"
    case travel = "Travel"
    case bills = "Bills"
    case entertainment = "Entertainment"
    case general = "General"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .travel: return "car.fill"
        case .bills: return "doc.text.fill"
        case .entertainment: return "tv.fill"
        case .general: return "creditcard.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .food: return Color(red: 0.96, green: 0.55, blue: 0.15)
        case .shopping: return Color(red: 0.85, green: 0.35, blue: 0.95)
        case .travel: return Color(red: 0.25, green: 0.65, blue: 0.95)
        case .bills: return Color(red: 0.95, green: 0.35, blue: 0.35)
        case .entertainment: return Color(red: 0.55, green: 0.45, blue: 0.95)
        case .general: return Color(red: 0.45, green: 0.75, blue: 0.65)
        }
    }
}

/// Core Bill Model
public struct Bill: Identifiable, Codable, Hashable {
    public let id: UUID
    public var amount: Double
    public var category: BillCategory
    public var date: Date
    public var vendorName: String
    public var imagePath: String?
    public var note: String?
    
    public init(
        id: UUID = UUID(),
        amount: Double,
        category: BillCategory,
        date: Date = Date(),
        vendorName: String = "Merchant",
        imagePath: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.vendorName = vendorName
        self.imagePath = imagePath
        self.note = note
    }
    
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(Int(amount))"
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Sample Data
extension Bill {
    public static var samples: [Bill] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Bill(
                amount: 1450,
                category: .food,
                date: now,
                vendorName: "Starbucks Coffee"
            ),
            Bill(
                amount: 3890,
                category: .shopping,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                vendorName: "Zara Apparel"
            ),
            Bill(
                amount: 620,
                category: .travel,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                vendorName: "Uber Ride"
            ),
            Bill(
                amount: 2400,
                category: .bills,
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                vendorName: "Electricity Board"
            ),
            Bill(
                amount: 1250,
                category: .food,
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                vendorName: "Olive Garden"
            )
        ]
    }
}
