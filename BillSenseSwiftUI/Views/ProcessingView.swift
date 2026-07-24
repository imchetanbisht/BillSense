import SwiftUI

public struct ProcessingView: View {
    @ObservedObject public var scannerVM: BillScannerViewModel
    public var onCompletion: (Bill, AIReport) -> Void
    
    @State private var rotationDegrees: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    public init(
        scannerVM: BillScannerViewModel,
        onCompletion: @escaping (Bill, AIReport) -> Void
    ) {
        self.scannerVM = scannerVM
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        ZStack {
            Theme.Gradients.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 36) {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Theme.Colors.accentIndigo.opacity(0.3), lineWidth: 12)
                        .scaleEffect(pulseScale)
                        .opacity(2.0 - pulseScale)
                        .frame(width: 220, height: 220)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                                pulseScale = 1.35
                            }
                        }
                    
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge)
                        .fill(LinearGradient(colors: [Color.indigo.opacity(0.4), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 200, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge)
                                .stroke(Theme.Colors.glassBorder, lineWidth: 1)
                        )
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 54))
                                    .foregroundColor(.white)
                                Text("Analyzing Image")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        )
                        .shadow(color: Theme.Colors.accentIndigo.opacity(0.5), radius: 25, x: 0, y: 10)
                    
                    LaserScannerView(speed: 1.5)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusLarge))
                }
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0.0, to: 0.7)
                            .stroke(Theme.Gradients.accentLinear, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(rotationDegrees))
                            .onAppear {
                                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                    rotationDegrees = 360
                                }
                            }
                    }
                    
                    VStack(spacing: 8) {
                        Text(scannerVM.scanState.statusTitle)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .transition(.opacity.combined(with: .slide))
                            .id(scannerVM.scanState.statusTitle)
                        
                        Text("AI is processing extracted data & running lens OCR detection")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .task {
            await scannerVM.startProcessPipeline()
            if case let .completed(bill, report) = scannerVM.scanState {
                onCompletion(bill, report)
            }
        }
    }
}

#Preview {
    ProcessingView(scannerVM: BillScannerViewModel(), onCompletion: { _, _ in })
}
