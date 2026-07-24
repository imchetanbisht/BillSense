import SwiftUI
import Combine

@MainActor
public class BillStore: ObservableObject {
    @Published public var bills: [Bill] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategoryFilter: BillCategory? = nil
    
    public init(initialBills: [Bill] = Bill.samples) {
        self.bills = initialBills
    }
    
    // MARK: - Computed Properties
    
    public var filteredBills: [Bill] {
        bills.filter { bill in
            let matchesSearch = searchText.isEmpty ||
                bill.vendorName.localizedCaseInsensitiveContains(searchText) ||
                bill.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.0f", bill.amount).contains(searchText)
            
            let matchesCategory = selectedCategoryFilter == nil || bill.category == selectedCategoryFilter
            return matchesSearch && matchesCategory
        }
    }
    
    public var totalSpending: Double {
        bills.reduce(0) { $0 + $1.amount }
    }
    
    public var averageSpending: Double {
        guard !bills.isEmpty else { return 0 }
        return totalSpending / Double(bills.count)
    }
    
    public var totalEstimatedSavings: Double {
        totalSpending * 0.22
    }
    
    public var groupedByDate: [String: [Bill]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        return Dictionary(grouping: filteredBills) { bill in
            formatter.string(from: bill.date)
        }
    }
    
    // MARK: - Actions
    
    public func addBill(_ bill: Bill) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            bills.insert(bill, at: 0)
        }
    }
    
    public func deleteBill(_ bill: Bill) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            bills.removeAll { $0.id == bill.id }
        }
    }
    
    public func categoryTotal(for category: BillCategory) -> Double {
        bills.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }
}
