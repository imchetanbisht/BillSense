import SwiftUI
import Combine

public enum ScanState: Equatable {
    case idle
    case scanning
    case extractingAmount
    case analyzingCategory
    case completed(Bill, AIReport)
    case failed(String)
    
    public var statusTitle: String {
        switch self {
        case .idle: return "Ready to Scan"
        case .scanning: return "Scanning Bill with OCR..."
        case .extractingAmount: return "Detecting Lens-Style Amount..."
        case .analyzingCategory: return "Analyzing Expense Category..."
        case .completed: return "Scan Complete!"
        case .failed(let err): return "Error: \(err)"
        }
    }
}

@MainActor
public class BillScannerViewModel: ObservableObject {
    @Published public var selectedImageName: String? = nil
    @Published public var scanState: ScanState = .idle
    @Published public var isScanningActive: Bool = false
    @Published public var detectedAmount: Double = 0.0
    @Published public var detectedCategory: BillCategory = .general
    @Published public var currentReport: AIReport? = nil
    @Published public var latestBill: Bill? = nil
    
    public init() {}
    
    public func selectSampleImage(named name: String = "receipt_sample") {
        self.selectedImageName = name
    }
    
    public func resetScanner() {
        self.selectedImageName = nil
        self.scanState = .idle
        self.isScanningActive = false
        self.detectedAmount = 0.0
        self.currentReport = nil
        self.latestBill = nil
    }
    
    public func startProcessPipeline(withMockAmount customAmount: Double? = nil) async {
        isScanningActive = true
        scanState = .scanning
        
        // Step 1: Simulated OCR Scanning
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        scanState = .extractingAmount
        
        // Step 2: Amount Detection
        let amount = customAmount ?? Double([1250, 2480, 3150, 890, 4500].randomElement() ?? 1800)
        self.detectedAmount = amount
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Step 3: Categorization
        scanState = .analyzingCategory
        let categories: [BillCategory] = [.food, .shopping, .bills, .travel, .entertainment]
        let category = categories.randomElement() ?? .food
        self.detectedCategory = category
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Step 4: Construct Bill & AI Report
        let newBill = Bill(
            amount: amount,
            category: category,
            date: Date(),
            vendorName: "\(category.rawValue) Store"
        )
        let report = AIReport.generateMockReport(for: newBill)
        
        self.latestBill = newBill
        self.currentReport = report
        self.isScanningActive = false
        self.scanState = .completed(newBill, report)
    }
}
