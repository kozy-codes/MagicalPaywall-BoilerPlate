//
//  ContentView.swift
//  Magical Paywall Boilerplate
//
//  Created by KJ
//  X: https://x.com/kozycodes
//

import SwiftUI

struct ContentView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 60))
                
                Text("Paywall Boilerplate Demo")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This is a demo showcasing the magical paywall boilerplate for iOS apps")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // Subscription Status
                    HStack {
                        Image(systemName: purchaseManager.isSubscribed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(purchaseManager.isSubscribed ? .green : .red)
                        
                        Text(purchaseManager.isSubscribed ? "Pro Subscriber" : "Free User")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Credits Display
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Credits: \(purchaseManager.credits == Int.max ? "Unlimited" : "\(purchaseManager.credits)")")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // Show Paywall Button
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Show Paywall")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Demo Action Button
                Button {
                    demoAction()
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Use Premium Feature (Costs 1 Credit)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(purchaseManager.credits > 0 ? Color.purple : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(purchaseManager.credits <= 0)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Demo App")
            .fullScreenCover(isPresented: $showPaywall) {
                MagicalPaywallView(
                    onSubscriptionSuccess: {
                        // Handle successful subscription
                        print("User subscribed successfully!")
                    }
                )
            }
        }
    }
    
    private func demoAction() {
        if purchaseManager.useCredit() {
            print("Premium feature used! Credits remaining: \(purchaseManager.credits)")
        } else {
            showPaywall = true
        }
    }
}

#Preview {
    ContentView()
}
