import SwiftUI

public struct HistoryView: View {
    @EnvironmentObject private var billStore: BillStore
    @State private var selectedBillForDetail: Bill? = nil
    @State private var billToDelete: Bill? = nil
    @State private var showDeleteConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // MARK: - Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.Colors.textMuted)
                        
                        TextField("Search merchant or category...", text: $billStore.searchText)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .autocapitalization(.none)
                        
                        if !billStore.searchText.isEmpty {
                            Button(action: { billStore.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                                    .stroke(Theme.Colors.glassBorder, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, Theme.Layout.paddingStandard)
                    
                    // MARK: - Category Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All",
                                isSelected: billStore.selectedCategoryFilter == nil
                            ) {
                                withAnimation { billStore.selectedCategoryFilter = nil }
                            }
                            
                            ForEach(BillCategory.allCases) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    icon: category.iconName,
                                    isSelected: billStore.selectedCategoryFilter == category
                                ) {
                                    withAnimation { billStore.selectedCategoryFilter = category }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingStandard)
                    }
                    
                    // MARK: - Empty State vs Grouped Bill List
                    if billStore.filteredBills.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "receipt")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.Colors.textMuted)
                            
                            Text("No Scanned Bills Found")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Text("Scan a receipt to start building your expense history")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.textMuted)
                        }
                        Spacer()
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(billStore.groupedByDate.keys.sorted(by: >), id: \.self) { dateKey in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(dateKey)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .padding(.horizontal, 4)
                                        
                                        if let dateBills = billStore.groupedByDate[dateKey] {
                                            ForEach(dateBills) { bill in
                                                BillRowItem(bill: bill) {
                                                    selectedBillForDetail = bill
                                                } onDelete: {
                                                    billToDelete = bill
                                                    showDeleteConfirmation = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Layout.paddingStandard)
                            .padding(.bottom, 90)
                        }
                    }
                }
                .padding(.top, 12)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedBillForDetail) { bill in
                ReportView(bill: bill, report: AIReport.generateMockReport(for: bill))
            }
            .alert("Delete Bill", isPresented: $showDeleteConfirmation, presenting: billToDelete) { bill in
                Button("Delete", role: .destructive) {
                    billStore.deleteBill(bill)
                }
                Button("Cancel", role: .cancel) {}
            } message: { bill in
                Text("Are you sure you want to delete the bill for \(bill.vendorName) (\(bill.formattedAmount))?")
            }
        }
    }
}

// MARK: - Subviews
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Theme.Colors.accentIndigo : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Theme.Colors.accentIndigo : Theme.Colors.glassBorder, lineWidth: 1)
            )
        }
    }
}

struct BillRowItem: View {
    let bill: Bill
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassCard(padding: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(bill.category.color.opacity(0.18))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: bill.category.iconName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(bill.category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bill.vendorName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(bill.formattedTime)
                            .font(.caption)
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                    
                    Spacer()
                    
                    Text(bill.formattedAmount)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.accentEmerald)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.accentCoral.opacity(0.8))
                            .padding(8)
                            .background(Theme.Colors.accentCoral.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .buttonStyle(InteractiveGlassCardStyle())
    }
}

#Preview {
    HistoryView()
        .environmentObject(BillStore())
}
