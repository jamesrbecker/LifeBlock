import SwiftUI
import StoreKit

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchases = PurchaseManager.shared

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Features list
                    featuresSection

                    // Pricing options
                    pricingSection

                    // Purchase button
                    purchaseButton

                    // Restore & Terms
                    footerSection
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await purchases.loadProducts()
                selectedProduct = purchases.yearlyProduct
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Unlock Your Full Potential")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Get unlimited habits, all widget sizes, and premium features to maximize your growth.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(PricingInfo.features, id: \.title) { feature in
                HStack(spacing: 16) {
                    Image(systemName: feature.icon)
                        .font(.title2)
                        .foregroundStyle(Color.accentGreen)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.headline)

                        Text(feature.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Yearly option (recommended)
            if let yearly = purchases.yearlyProduct {
                PricingOptionView(
                    product: yearly,
                    isSelected: selectedProduct?.id == yearly.id,
                    badge: "Best Value",
                    savings: "Save 33%"
                ) {
                    selectedProduct = yearly
                }
            }

            // Monthly option
            if let monthly = purchases.monthlyProduct {
                PricingOptionView(
                    product: monthly,
                    isSelected: selectedProduct?.id == monthly.id,
                    badge: nil,
                    savings: nil
                ) {
                    selectedProduct = monthly
                }
            }

            // Loading state
            if purchases.isLoading && purchases.products.isEmpty {
                ProgressView()
                    .padding()
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            Task {
                await purchase()
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Continue")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.accentGreen, Color.accentGreen.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(selectedProduct == nil || isPurchasing)
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await purchases.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private func purchase() async {
        guard let product = selectedProduct else { return }

        isPurchasing = true

        do {
            let transaction = try await purchases.purchase(product)
            if transaction != nil {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isPurchasing = false
    }
}

struct PricingOptionView: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let savings: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)

                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }

                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let savings = savings {
                        Text(savings)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentGreen.opacity(0.15) : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.accentGreen : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Future Preview Card (for motivational display)

struct FuturePreviewCard: View {
    let currentStreak: Int

    private var preview: (title: String, message: String) {
        NotificationManager.generateFuturePreview(currentStreak: currentStreak)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text(preview.title)
                    .font(.headline)
            }

            Text(preview.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PremiumView()
        .preferredColorScheme(.dark)
}
