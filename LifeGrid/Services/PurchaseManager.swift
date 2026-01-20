import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let productIDs = [
        "com.lifegrid.premium.monthly",
        "com.lifegrid.premium.yearly"
    ]

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Products

    var monthlyProduct: Product? {
        products.first { $0.id == "com.lifegrid.premium.monthly" }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == "com.lifegrid.premium.yearly" }
    }

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return transaction

            case .userCancelled:
                isLoading = false
                return nil

            case .pending:
                isLoading = false
                errorMessage = "Purchase is pending approval"
                return nil

            @unknown default:
                isLoading = false
                return nil
            }
        } catch {
            isLoading = false
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false

            if purchasedProductIDs.isEmpty {
                errorMessage = "No purchases to restore"
            }
        } catch {
            isLoading = false
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Transaction Handling

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Error checking entitlement: \(error)")
            }
        }

        purchasedProductIDs = purchased

        // Update shared subscription status
        SubscriptionStatus.shared.updateStatus(isPremium: !purchased.isEmpty)
    }

    // MARK: - Subscription Info

    func getSubscriptionStatus() async -> (isActive: Bool, expirationDate: Date?, willRenew: Bool) {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if productIDs.contains(transaction.productID) {
                let isActive = transaction.revocationDate == nil
                return (isActive, transaction.expirationDate, transaction.revocationDate == nil)
            }
        }

        return (false, nil, false)
    }
}

// MARK: - Errors

enum StoreError: LocalizedError {
    case verificationFailed
    case productNotFound
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

// MARK: - Price Formatting

extension Product {
    var formattedPrice: String {
        self.displayPrice
    }

    var pricePerMonth: String {
        if self.id.contains("yearly") {
            let monthlyPrice = self.price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = self.priceFormatStyle.locale
            return formatter.string(from: monthlyPrice as NSDecimalNumber) ?? ""
        }
        return self.displayPrice
    }
}
