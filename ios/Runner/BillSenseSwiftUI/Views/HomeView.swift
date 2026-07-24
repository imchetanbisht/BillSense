import SwiftUI

public struct HomeView: View {
    @EnvironmentObject private var billStore: BillStore
    @StateObject private var scannerVM = BillScannerViewModel()
    @Binding public var selectedTab: Int
    
    @State private var showProcessingSheet: Bool = false
    @State private var showReportSheet: Bool = false
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Header
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.Gradients.accentLinear)
                                    .frame(width: 52, height: 52)
                                    .shadow(color: Theme.Colors.accentIndigo.opacity(0.4), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: "receipt")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BillSense AI")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("Smart Expense Tracker")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // User Profile Avatar
                            Button(action: {}) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(.top, 8)
                        
                        // MARK: - Scan Hero Card
                        GlassCard {
                            VStack(spacing: 20) {
                                // Animated Pulse Icon
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.accentIndigo.opacity(pulseScannerIcon ? 0.25 : 0.1))
                                        .frame(width: pulseScannerIcon ? 90 : 76, height: pulseScannerIcon ? 90 : 76)
                                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScannerIcon)
                                    
                                    Image(systemName: "doc.viewfinder")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(Theme.Colors.accentIndigo)
                                }
                                .onAppear { pulseScannerIcon = true }
                                
                                VStack(spacing: 6) {
                                    Text("Scan Your Bill")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text("Capture or upload a receipt to auto-extract text & generate insights")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                
                                // Camera / Upload Action Row
                                HStack(spacing: 14) {
                                    Button(action: {
                                        withAnimation { mockImageSelected = true }
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Camera")
                                                .fontWeight(.semibold)
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
                                        HStack {
                                            Image(systemName: "photo.fill")
                                            Text("Upload")
                                                .fontWeight(.semibold)
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
                                
                                // Selected Image Preview with Laser Scanning Overlay
                                if mockImageSelected {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium)
                                            .fill(LinearGradient(colors: [Color.indigo.opacity(0.3), Color.purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(height: 160)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    Image(systemName: "doc.text.fill")
                                                        .font(.system(size: 36))
                                                        .foregroundColor(.white.opacity(0.8))
                                                    Text("Sample Receipt Loaded")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                }
                                            )
                                        
                                        LaserScannerView(speed: 2.0)
                                            .frame(height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusMedium))
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                                
                                // Start Scan Primary CTA
                                Button(action: {
                                    showProcessingSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text("Start AI Scan")
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
                        
                        // MARK: - Features Grid Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Features")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                FeatureCard(
                                    title: "Insights",
                                    subtitle: "AI spending analysis",
                                    iconName: "chart.xyaxis.line",
                                    color: Theme.Colors.accentIndigo
                                ) {
                                    selectedTab = 1
                                }
                                
                                FeatureCard(
                                    title: "Savings",
                                    subtitle: "Future predictions",
                                    iconName: "leaf.fill",
                                    color: Theme.Colors.accentEmerald
                                ) {
                                    selectedTab = 2
                                }
                                
                                FeatureCard(
                                    title: "AI Tips",
                                    subtitle: "Smart suggestions",
                                    iconName: "lightbulb.fill",
                                    color: Theme.Colors.accentAmber
                                ) {
                                    selectedTab = 3
                                }
                                
                                FeatureCard(
                                    title: "History",
                                    subtitle: "All scanned bills",
                                    iconName: "clock.arrow.circlepath",
                                    color: Theme.Colors.accentPurple
                                ) {
                                    selectedTab = 4
                                }
                            }
                        }
                        
                        Spacer(minLength: 80)
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
        }
    }
}

// MARK: - Subviews
struct FeatureCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassCard(padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(color)
                    
                    Spacer(minLength: 10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.Colors.textMuted)
                    }
                }
                .frame(height: 110, alignment: .topLeading)
            }
        }
        .buttonStyle(InteractiveGlassCardStyle())
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(BillStore())
}
