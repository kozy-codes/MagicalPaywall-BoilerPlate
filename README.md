# 🎨 Magical Paywall Boilerplate

A beautiful, production-ready SwiftUI paywall with RevenueCat integration. Perfect for iOS apps that need subscription monetization.

## 👨‍💻 About

**Created by KJ**

X: https://x.com/kozycodes

## ✨ Features

- **Beautiful UI**: Modern glassmorphism design with smooth animations
- **RevenueCat Ready**: Complete subscription management setup (commented for easy implementation)
- **Intro Offers**: Special discount offers for new users
- **Before/After Showcase**: Image carousel to demonstrate your app's value
- **Credit System**: Built-in credit management for freemium apps
- **Responsive Design**: Works on iPhone and iPad
- **Success Animations**: Delightful user feedback
- **Mock Implementation**: Works out of the box for testing and development

## 🚀 Quick Start

### 1. Copy the Files

Copy these files to your project:
- `MagicalPaywallView.swift` - The main paywall view
- `PurchaseManager.swift` - Subscription and credit management

### 2. Install RevenueCat (Optional)

Add RevenueCat to your project using Swift Package Manager:

```
https://github.com/RevenueCat/purchases-ios
```

### 3. Configure RevenueCat (When Ready)

1. Create an account at [RevenueCat](https://www.revenuecat.com/)
2. Set up your app and products
3. Uncomment the RevenueCat code in `PurchaseManager.swift`
4. Replace `YOUR_REVENUECAT_API_KEY` with your actual API key

### 4. Add Images (Optional)

Add your before/after images to `Assets.xcassets`:
- `before_1` through `before_4`
- `after_1` through `after_4`

Or use the placeholder images that are included.

### 5. Customize

Update the following in `MagicalPaywallView.swift`:
- App name and branding
- Feature descriptions
- Terms of Service and Privacy Policy URLs
- UserDefaults keys to match your app

## 📱 Usage

### Basic Implementation

```swift
import SwiftUI

struct ContentView: View {
    @State private var showPaywall = false
    
    var body: some View {
        VStack {
            Button("Show Paywall") {
                showPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            MagicalPaywallView(
                onSubscriptionSuccess: {
                    // Handle successful subscription
                    print("User subscribed!")
                }
            )
        }
    }
}
```

### With Credit System

```swift
@StateObject private var purchaseManager = PurchaseManager.shared

private func performAction() {
    if purchaseManager.useCredit() {
        // Perform the action
        doSomething()
    } else {
        // Show paywall
        showPaywall = true
    }
}
```

## 🎨 Customization

### Colors and Branding

The paywall uses a purple/blue gradient theme. To customize:

1. Update the gradient colors in `MagicalPaywallView.swift`
2. Modify the `premiumButtonBackground` function for different button styles
3. Change the accent colors throughout the view

### Features List

Update the `features` array in `MagicalPaywallView.swift`:

```swift
private let features = [
    FeatureItem(icon: "your.icon", text: "Your feature description"),
    // Add more features...
]
```

### Pricing Plans

The paywall currently uses mock data. When you implement RevenueCat, it will automatically load your configured subscription products.

## 🔧 Implementation Steps

### Phase 1: Mock Implementation (Current)
- ✅ Beautiful paywall UI
- ✅ Mock purchase flow
- ✅ Credit system
- ✅ Success animations

### Phase 2: RevenueCat Integration
1. Uncomment RevenueCat imports and code
2. Add your API key
3. Configure your products in RevenueCat dashboard
4. Test in sandbox mode

### Phase 3: Production
1. Test thoroughly in sandbox
2. Submit for App Store review
3. Configure production environment
4. Monitor analytics and conversion rates

## 🛠 Architecture

```
MagicalPaywallView
├── PurchaseManager (Subscription & credit management)
├── MockPricingCard (Individual subscription options)
├── FeatureItem (Feature list model)
└── Extensions (Color utilities)
```

## 🎯 Key Components

### MagicalPaywallView
- Main paywall interface
- Intro offer overlay
- Success animations
- Before/after showcase

### PurchaseManager
- Mock implementation ready
- RevenueCat integration prepared
- Credit management system
- Subscription state handling

### MockPricingCard
- Beautiful pricing display
- Selection animations
- Discount highlighting
- Responsive design

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- RevenueCat SDK (optional, for production)

## 🎯 Best Practices

1. **Test Thoroughly**: The mock implementation lets you test the UI immediately
2. **Gradual Implementation**: Start with mock, then add RevenueCat when ready
3. **Handle Errors**: Implement proper error handling for network issues
4. **Accessibility**: The paywall includes accessibility features
5. **Performance**: Images are optimized for smooth scrolling
6. **Analytics**: Consider adding analytics to track conversion rates

## 🔄 Migration from Mock to RevenueCat

When you're ready to implement RevenueCat:

1. Uncomment all RevenueCat code in `PurchaseManager.swift`
2. Update the import statements
3. Replace mock data with actual RevenueCat calls
4. Update `MagicalPaywallView.swift` to use real packages
5. Test in RevenueCat's sandbox environment

## 📝 License

This boilerplate is open source and free to use in your projects. Attribution appreciated but not required.

**Happy monetizing! 💰** 