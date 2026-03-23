import Foundation
import RevenueCat

@MainActor
final class DonorManager: ObservableObject {
    static let shared = DonorManager()

    @Published private(set) var donorTier: DonorTier = .none
    @Published private(set) var totalDonated: Double = 0
    @Published private(set) var donationCount: Int = 0
    private let logger = Logger(logLevel: .info)

    private static let productPrices: [String: Double] = [
        "saes_donation_499": 4.99,
        "saes_donation_1499": 14.99,
        "saes_donation_2499": 24.99,
    ]

    private init() {}

    private static let entitlementIDs: [(id: String, tier: DonorTier)] = [
        ("donor_champion", .champion),
        ("donor_patron", .patron),
        ("donor_supporter", .supporter),
    ]

    var isDonor: Bool { donorTier != .none }

    func refreshStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateTier(from: customerInfo)
        } catch {
            logger.log(level: .error, message: "Failed to fetch donor status: \(error.localizedDescription)", source: "DonorManager")
        }
    }

    func listenForChanges() async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            updateTier(from: customerInfo)
        }
    }

    private func updateTier(from customerInfo: CustomerInfo) {
        var resolved: DonorTier = .none
        for (id, tier) in Self.entitlementIDs {
            if customerInfo.entitlements[id]?.isActive == true {
                resolved = max(resolved, tier)
            }
        }
        if donorTier != resolved {
            donorTier = resolved
            logger.log(level: .info, message: "Donor tier updated: \(resolved)", source: "DonorManager")
        }
        updateDonationStats(from: customerInfo)
    }

    private func updateDonationStats(from customerInfo: CustomerInfo) {
        let transactions = customerInfo.nonSubscriptions
        donationCount = transactions.count
        totalDonated = transactions.reduce(0) { sum, transaction in
            sum + (Self.productPrices[transaction.productIdentifier] ?? 0)
        }
    }
}
