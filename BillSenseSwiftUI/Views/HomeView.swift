import SwiftUI

public struct HomeView: View {
    @EnvironmentObject private var billStore: BillStore
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var scannerVM = BillScannerViewModel()
    @Binding public var selectedTab: Int
    
    @State private var showProcessingSheet: Bool = false
    @State private var showReportSheet: Bool = false
    @State private var selectedBillForDetail: Bill? = nil
    @State private var mockImageSelected: Bool = false
    @State private var pulseScannerIcon: Bool = false
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Theme.Gradients.mainBackground
                    .ignoresSafeArea()
                
                // Top Ambient Light Halo
                Circle()
                    .fill(Theme.Colors.accentIndigo.opacity(0.18))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(x: -80, y: -200)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Premium Top Bar Header
                        HStack(spacing: 14) {
                            // User Avatar with Online Status Indicator Ring
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(Theme.Gradients.accentLinear)
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: Theme.Colors.accentIndigo.opacity(0.4), radius: 10, x: 0, y: 4)
                                
                                Circle()
                                    .fill(Theme.Colors.accentEmerald)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Theme.Colors.backgroundPrimary, lineWidth: 2))
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hello, Alex 👋")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("BillSense AI Dashboard")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Notification Bell & Logout Menu
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .padding(10)
                                            .background(Circle().fill(Color.white.opacity(0.06)))
                                        
                                        Circle()
                                            .fill(Theme.Colors.accentCoral)
                                            .frame(width: 8, height: 8)
                                            .offset(x: -2, y: 2)
                                    }
                                }
                                
                                Button(action: { authVM.logout() }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.Colors.accentCoral)
                                        .padding(10)
                                        .background(Circle().fill(Theme.Colors.accentCoral.opacity(0.15)))
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        // MARK: - Hero Scanner Glass Card
                        GlassCard {
                            VStack(spacing: 20) {
                                // Double Glowing Pulse Ring Icon
                                ZStack {
                                    Circle()
                                        .stroke(Theme.Colors.accentIndigo.opacity(0.3), lineWidth: 2)
                                        .frame(width: pulseScannerIcon ? 100 : 84, height: pulseScannerIcon ? 100 : 84)
                                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulseScannerIcon)
                                    
                                    Circle()
                                        .fill(Theme.Colors.accentIndigo.opacity(pulseScannerIcon ? 0.25 : 0.12))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "doc.viewfinder")
                                        .font(.system(size: 38, weight: .bold))
                                        .foregroundColor(Theme.Colors.accentIndigo)
                                }
                                .onAppear { pulseScannerIcon = true }
                                
                                VStack(spacing: 6) {
                                    Text("Scan Receipt & Extract Data")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text("Capture or upload a bill image to auto-detect amounts & generate AI tips")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                
                                // Camera & Gallery Pickers
                                HStack(spacing: 12) {
                                    Button(action: {
                                        withAnimation { mockImageSelected = true }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                            Text("Camera")
                                                .fontWeight(.bold)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(Theme.Layout.cornerRadiusSmall)
                                    }
                                    .buttonStyle(InteractiveGlassCardStyle())
                                    
                                    Button(action: {
                                        withAnimation { mockImageSelected = true }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.fill")
                                            Text("Gallery")
                                                .fontWeight(.bold)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(Theme.Layout.cornerRadiusSmall)
                                    }
                                    .buttonStyle(InteractiveGlassCardStyle())
                                }
                                
                                // Selected Image Live Laser Scan Frame
                                if mockImageSelected {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                                            .fill(LinearGradient(colors: [Color.indigo.opacity(0.35), Color.purple.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(height: 160)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    Image(systemName: "doc.text.fill")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.white.opacity(0.9))
                                                    Text("Receipt Image Loaded")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                }
                                            )
                                        
                                        LaserScannerView(speed: 1.8)
                                            .frame(height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium))
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                                
                                // Primary CTA Button
                                Button(action: {
                                    showProcessingSheet = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                        Text("Start AI Scan Pipeline")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Theme.Gradients.accentLinear)
                                    .cornerRadius(Theme.Layout.cornerRadiusMedium)
                                    .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 12, x: 0, y: 6)
                                }
                                .buttonStyle(InteractiveGlassCardStyle())
                            }
                        }
                        
                        // MARK: - Quick Metrics Scroll Row
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Analytics Summary")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Total Spent",
                                    value: "₹\(Int(billStore.totalSpending))",
                                    subtitle: "+14% vs last mo",
                                    iconName: "wallet.pass.fill",
                                    accentColor: Theme.Colors.accentIndigo
                                )
                                
                                StatCard(
                                    title: "AI Savings",
                                    value: "₹\(Int(billStore.totalEstimatedSavings))",
                                    subtitle: "22% optimized",
                                    iconName: "leaf.fill",
                                    accentColor: Theme.Colors.accentEmerald
                                )
                            }
                        }
                        
                        // MARK: - Interactive 2x2 Feature Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Core Features")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                FeatureCard(
                                    title: "Insights",
                                    subtitle: "AI spending analysis",
                                    iconName: "chart.xyaxis.line",
                                    color: Theme.Colors.accentIndigo
                                ) { selectedTab = 1 }
                                
                                FeatureCard(
                                    title: "Savings",
                                    subtitle: "Future predictions",
                                    iconName: "leaf.fill",
                                    color: Theme.Colors.accentEmerald
                                ) { selectedTab = 2 }
                                
                                FeatureCard(
                                    title: "AI Tips",
                                    subtitle: "Smart recommendations",
                                    iconName: "lightbulb.fill",
                                    color: Theme.Colors.accentAmber
                                ) { selectedTab = 3 }
                                
                                FeatureCard(
                                    title: "History",
                                    subtitle: "All scanned bills",
                                    iconName: "clock.arrow.circlepath",
                                    color: Theme.Colors.accentPurple
                                ) { selectedTab = 4 }
                            }
                        }
                        
                        // MARK: - Recent Activity Live Feed
                        if !billStore.bills.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Recent Activity")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    Spacer()
                                    Button(action: { selectedTab = 4 }) {
                                        Text("View All")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.Colors.accentIndigo)
                                    }
                                }
                                
                                ForEach(billStore.bills.prefix(3)) { bill in
                                    Button(action: { selectedBillForDetail = bill }) {
                                        GlassCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(bill.category.color.opacity(0.18))
                                                        .frame(width: 40, height: 40)
                                                    Image(systemName: bill.category.iconName)
                                                        .font(.system(size: 18, weight: .bold))
                                                        .foregroundColor(bill.category.color)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(bill.vendorName)
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Theme.Colors.textPrimary)
                                                    Text("\(bill.category.rawValue) • \(bill.formattedDate)")
                                                        .font(.caption2)
                                                        .foregroundColor(Theme.Colors.textMuted)
                                                }
                                                
                                                Spacer()
                                                
                                                Text(bill.formattedAmount)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(Theme.Colors.accentEmerald)
                                            }
                                        }
                                    }
                                    .buttonStyle(InteractiveGlassCardStyle())
                                }
                            }
                        }
                        
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, Theme.Layout.paddingStandard)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showProcessingSheet) {
                ProcessingView(scannerVM: scannerVM) { bill, report in
                    billStore.addBill(bill)
                    showProcessingSheet = false
                    showReportSheet = true
                }
            }
            .sheet(isPresented: $showReportSheet) {
                if let bill = scannerVM.latestBill, let report = scannerVM.currentReport {
                    ReportView(bill: bill, report: report)
                }
            }
            .sheet(item: $selectedBillForDetail) { bill in
                ReportView(bill: bill, report: AIReport.generateMockReport(for: bill))
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(BillStore())
        .environmentObject(AuthViewModel())
}
