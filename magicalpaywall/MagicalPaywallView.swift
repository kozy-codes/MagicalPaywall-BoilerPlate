//
//  MagicalPaywallView.swift
//  Magical Paywall Boilerplate
//
//  Created by KJ
//  X: https://x.com/kozycodes
//

import SwiftUI
// Note: You'll need to add RevenueCat as a dependency to your project
// import RevenueCat

// MARK: - Feature Item Model
struct FeatureItem: Identifiable {
    var id: String { text }
    let icon: String
    let text: String
}

// MARK: - Main Paywall View
struct MagicalPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var selectedPlanIndex = 1 // Default to annual (better value)
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var glowIntensity = 0.3
    @State private var currentImageIndex = 0
    @State private var isAnimating = false
    @State private var sparkleEffect = true
    @State private var showingSuccess = false
    @State private var successScale: CGFloat = 0.8
    @State private var showIntroOffer = false
    @State private var introScale: CGFloat = 0.8
    @State private var hasClaimedOffer: Bool = UserDefaults.standard.bool(forKey: "com.yourapp.specialOfferClaimed")
    
    // Key for UserDefaults to track if the offer has been shown
    private let offerShownKey = "com.yourapp.specialOfferClaimed"
    
    // RevenueCat integration - uncomment when you add RevenueCat
    // @ObservedObject private var purchaseManager = PurchaseManager.shared
    
    // Mock data for preview - replace with actual PurchaseManager
    @State private var mockPackages: [String] = ["Weekly", "Annual"]
    
    // Add TransformViewModel (optional - for your specific use case)
    var transformViewModel: TransformViewModel?
    
    // Callback for subscription success
    var onSubscriptionSuccess: (() -> Void)?
    
    // Sample image pairs for the carousel - you'll need to add these images to your Assets
    private let beforeAfterPairs: [(String, String)] = [
        ("before_1", "after_1"),
        ("before_2", "after_2"),
        ("before_3", "after_3"),
        ("before_4", "after_4"),
    ]
    
    // Timer for auto-scrolling
    private let carouselTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    private let features = [
        FeatureItem(icon: "wand.and.stars", text: "Unlimited premium features"),
        FeatureItem(icon: "photo.stack", text: "Access to all content"),
        FeatureItem(icon: "sparkles", text: "Premium quality results")
    ]
    
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyURL = URL(string: "https://yourapp.com/privacy-policy")!
    
    // Add view state management
    @State private var isViewVisible = false
    
    var body: some View {
        ZStack {
            // Base layer - deep background with more depth
            Color.black.ignoresSafeArea()
            
            // Enhanced gradient background - simplified
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.4),
                    Color.purple.opacity(0.2),
                    Color.blue.opacity(0.1),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 30)
            .ignoresSafeArea()
            
            if showingSuccess {
                successOverlay
            }
            
            if showIntroOffer && !hasClaimedOffer {
                introOfferOverlay
            }
            
            // Main content
            mainContent
            
            // Close button
            if !showingSuccess {
                closeButton
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupView()
        }
        .onDisappear {
            isViewVisible = false
        }
        .alert("Purchase Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var successOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .symbolEffect(.bounce)
            
            Text("Welcome to Pro! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Your subscription is now active")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .scaleEffect(successScale)
        .transition(.opacity)
        .zIndex(100)
    }
    
    private var introOfferOverlay: some View {
        ZStack {
            // Fullscreen background
            Color.black.ignoresSafeArea()
            
            // Enhanced gradient background
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.6),
                    Color.purple.opacity(0.4),
                    Color.blue.opacity(0.3),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blur(radius: 30)
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce.up, options: .repeating)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
                
                VStack(spacing: 16) {
                    Text("Special Offer! 🎉")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.3), radius: 10)
                    
                    Text("Unlock 50% discount on your first subscription")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        claimOffer()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .semibold))
                                .symbolEffect(.bounce.up.byLayer, options: .repeating, value: sparkleEffect)
                                .symbolEffect(.pulse.byLayer, options: .repeating, value: sparkleEffect)
                            
                            Text("Claim Offer")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: 280)
                        .frame(height: 65)
                        .background(premiumButtonBackground(color: .purple))
                        .foregroundColor(.white)
                    }
                    
                    Text("Limited introductory offer - first 4 weeks only")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 60)
            
            // Close button for the offer
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            showIntroOffer = false
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial.opacity(0.5))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .scaleEffect(introScale)
        .transition(.opacity)
        .zIndex(99)
    }
    
    private var mainContent: some View {
        VStack(spacing: 16) {
            // Header
            headerSection
            
            // Showcase
            showcaseSection
            
            // Pricing
            pricingSection
            
            // Features
            featuresSection
            
            // CTA Button
            ctaButton
            
            // Footer
            footerSection
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("App Pro")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .purple.opacity(0.5), radius: 8)
            
            Text("Unlock unlimited premium features")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 24)
    }
    
    private var showcaseSection: some View {
        ZStack {
            // Background with premium blur
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .blur(radius: 3)
            
            // Gradient overlay
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.15),
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.7)
            
            // Premium border with glow
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.5),
                            .purple.opacity(0.3),
                            .blue.opacity(0.3),
                            .white.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .blur(radius: 0.5)

            // Content
            HStack(spacing: 16) {
                // Before image
                imageCard(
                    imageName: beforeAfterPairs[currentImageIndex].0,
                    label: "Before"
                )
                
                // After image
                imageCard(
                    imageName: beforeAfterPairs[currentImageIndex].1,
                    label: "After"
                )
            }
            .padding(12)
        }
        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 180)
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
        .padding(.horizontal, 20)
        .shadow(color: .purple.opacity(0.2), radius: 20, x: 0, y: 10)
        .shadow(color: .blue.opacity(0.2), radius: 30, x: 0, y: 15)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            if mockPackages.isEmpty {
                HStack(spacing: 12) {
                    ForEach(0..<2) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 180)
                    }
                }
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                .padding(.horizontal, 20)
                .redacted(reason: .placeholder)
            } else {
                HStack(spacing: 12) {
                    ForEach(Array(mockPackages.enumerated()), id: \.offset) { index, packageName in
                        MockPricingCard(
                            packageName: packageName,
                            isSelected: selectedPlanIndex == index,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPlanIndex = index
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 8) {
            ForEach(features.prefix(3)) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.purple)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.2))
                                .background(.thinMaterial)
                                .clipShape(Circle())
                        )
                    
                    Text(feature.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 500 : .infinity)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var ctaButton: some View {
        Button {
            startPurchase()
        } label: {
            HStack(spacing: 8) {
                if !isPurchasing {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .symbolEffect(.bounce.up.byLayer, options: .repeating, value: sparkleEffect)
                        .symbolEffect(.pulse.byLayer, options: .repeating, value: sparkleEffect)
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity)
            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 55)
            .background(premiumButtonBackground(color: Color(hex: "4CD964")))
            .foregroundColor(.white)
        }
        .disabled(mockPackages.isEmpty || isPurchasing)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .opacity((mockPackages.isEmpty || isPurchasing) ? 0.7 : 1.0)
        .onAppear {
            sparkleEffect = true
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 4) {
            Button("Restore Purchases") {
                restorePurchases()
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.6))
            
            Text("Cancel anytime • No commitment")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
            
            HStack(spacing: 8) {
                Button("Terms of Service") {
                    openURL(termsURL)
                }
                Text("•")
                Button("Privacy Policy") {
                    openURL(privacyURL)
                }
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.4))
            .padding(.top, 4)
        }
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity)
        .padding(.bottom, 16)
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial.opacity(0.3))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            Spacer()
        }
        .zIndex(99)
    }
    
    // MARK: - Helper Methods
    
    private func setupView() {
        isViewVisible = true
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).speed(0.7)) {
            glowIntensity = 0.7
        }
        
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentImageIndex = (currentImageIndex + 1) % beforeAfterPairs.count
            }
        }
        
        if !hasClaimedOffer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showIntroOffer = true
                    introScale = 1.0
                }
            }
        }
    }
    
    private func imageCard(imageName: String, label: String) -> some View {
        VStack(spacing: 8) {
            // Placeholder for images - replace with your actual images
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 130, height: 140)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(Capsule().fill(Color.black.opacity(0.2)))
        }
    }
    
    private func premiumButtonBackground(color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .blur(radius: 3)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            color,
                            color.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.9)
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            color.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .blur(radius: 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 1)
                .blur(radius: 4)
                .padding(-2)
        )
        .shadow(color: color.opacity(0.5), radius: 10)
    }
    
    private func startPurchase() {
        guard !mockPackages.isEmpty else {
            errorMessage = "No subscription packages available"
            return
        }
        
        isPurchasing = true
        
        // Mock purchase flow - replace with actual RevenueCat implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPurchasing = false
            
            // Simulate successful purchase
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showingSuccess = true
                successScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onSubscriptionSuccess?()
                dismiss()
            }
        }
    }
    
    private func restorePurchases() {
        // Mock restore flow - replace with actual RevenueCat implementation
        errorMessage = "No previous purchases found"
    }
    
    private func claimOffer() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showIntroOffer = false
            hasClaimedOffer = true
            
            UserDefaults.standard.set(true, forKey: offerShownKey)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - Supporting Views

// Mock pricing card for preview - replace with actual RevenueCat PricingCard
struct MockPricingCard: View {
    let packageName: String
    let isSelected: Bool
    let action: () -> Void
    
    private var isPromoted: Bool {
        packageName == "Annual"
    }
    
    private var regularPrice: String {
        packageName == "Annual" ? "$59.99" : "$9.99"
    }
    
    private var salePrice: String {
        packageName == "Annual" ? "$29.99" : "$4.99"
    }
    
    private var periodText: String {
        packageName == "Annual" ? "per year" : "per week"
    }
    
    private var durationText: String {
        packageName == "Annual" ? "For first year" : "For first 4 weeks"
    }
    
    private var creditsText: String {
        packageName == "Annual" ? "500 Premium Credits" : "10 Premium Credits"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 4) {
                if isPromoted {
                    Text("BEST VALUE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.5))
                        .cornerRadius(4)
                        .padding(.bottom, 6)
                }
                
                Text(packageName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(regularPrice)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .strikethrough()
                
                Text("50% OFF")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.vertical, 2)
                
                Text(salePrice)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(durationText)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer().frame(height: 8)
                
                Text("Unlimited Access")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(creditsText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.yellow)
                    .padding(.top, 4)
    
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.2))
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .blur(radius: 3)
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: isSelected ? 
                                                [Color.purple.opacity(0.3), Color.blue.opacity(0.2)] :
                                                [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .opacity(0.7)
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: isSelected ?
                                                [.purple.opacity(0.6), .blue.opacity(0.3)] :
                                                [.white.opacity(0.3), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.8), .purple.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    }
                }
            )
            .shadow(color: isSelected ? .purple.opacity(0.2) : .clear, radius: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MagicalPaywallView()
} 
