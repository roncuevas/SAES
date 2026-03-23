import RevenueCat
import SwiftUI

struct RevenueCatDebugView: View {
    @State private var customerInfo: CustomerInfo?
    @State private var appUserID: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var apiKey: String {
        #if DEBUG
        "test_LPrNjxSdRisrGizyABhnPuftUPk"
        #else
        "appl_ezSsmdGCXIkeQKFpAPEXbJAYXOC"
        #endif
    }

    private var environment: String {
        #if DEBUG
        "Sandbox (DEBUG)"
        #else
        "Production"
        #endif
    }

    var body: some View {
        List {
            configSection
            userSection
            if let customerInfo {
                entitlementsSection(customerInfo)
                nonSubscriptionsSection(customerInfo)
                activeSubscriptionsSection(customerInfo)
            }
            if let errorMessage {
                errorSection(errorMessage)
            }
            actionsSection
        }
        .navigationTitle("RevenueCat Debug")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadData()
        }
    }

    // MARK: - Config

    private var configSection: some View {
        Section("Configuration") {
            row("Environment", environment)
            row("API Key", maskedKey)
            row("SDK Version", Purchases.frameworkVersion)
            row("Is Configured", "\(Purchases.isConfigured)")
        }
    }

    // MARK: - User

    private var userSection: some View {
        Section("User") {
            if isLoading {
                ProgressView()
            } else {
                row("App User ID", appUserID)
                row("Is Anonymous", "\(Purchases.shared.isAnonymous)")
                if let customerInfo {
                    row("First Seen", customerInfo.firstSeen.formatted())
                    row("Original App User ID", customerInfo.originalAppUserId)
                }
            }
        }
    }

    // MARK: - Entitlements

    private func entitlementsSection(_ info: CustomerInfo) -> some View {
        Section("Entitlements") {
            if info.entitlements.all.isEmpty {
                Text("No entitlements found")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(info.entitlements.all.keys.sorted()), id: \.self) { key in
                    if let entitlement = info.entitlements[key] {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(key)
                                    .font(.body)
                                Spacer()
                                Text(entitlement.isActive ? "Active" : "Inactive")
                                    .font(.caption)
                                    .foregroundStyle(entitlement.isActive ? .green : .red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(entitlement.isActive ? .green.opacity(0.15) : .red.opacity(0.15))
                                    )
                            }
                            Group {
                                Text("Product: \(entitlement.productIdentifier)")
                                if let expires = entitlement.expirationDate {
                                    Text("Expires: \(expires.formatted())")
                                }
                                if let purchase = entitlement.latestPurchaseDate {
                                    Text("Purchased: \(purchase.formatted())")
                                }
                                Text("Store: \(entitlement.store.rawValue)")
                                Text("Sandbox: \(entitlement.isSandbox ? "Yes" : "No")")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    // MARK: - Non-Subscriptions

    private func nonSubscriptionsSection(_ info: CustomerInfo) -> some View {
        Section("Non-Subscription Transactions") {
            if info.nonSubscriptions.isEmpty {
                Text("No transactions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(info.nonSubscriptions, id: \.transactionIdentifier) { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.productIdentifier)
                            .font(.body)
                        Group {
                            Text("ID: \(transaction.transactionIdentifier)")
                            Text("Date: \(transaction.purchaseDate.formatted())")
                            Text("Store: \(transaction.store.rawValue)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Active Subscriptions

    private func activeSubscriptionsSection(_ info: CustomerInfo) -> some View {
        Section("Active Subscriptions") {
            if info.activeSubscriptions.isEmpty {
                Text("No active subscriptions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(info.activeSubscriptions), id: \.self) { sub in
                    Text(sub)
                }
            }
        }
    }

    // MARK: - Error

    private func errorSection(_ message: String) -> some View {
        Section("Error") {
            Text(message)
                .foregroundStyle(.red)
                .font(.caption)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section("Actions") {
            Button {
                Task { await loadData() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            Button {
                Task {
                    try? await Purchases.shared.restorePurchases()
                    await loadData()
                }
            } label: {
                Label("Restore Purchases", systemImage: "cart")
            }
            Button {
                UIPasteboard.general.string = appUserID
            } label: {
                Label("Copy User ID", systemImage: "doc.on.doc")
            }
            Button {
                UIPasteboard.general.string = apiKey
            } label: {
                Label("Copy API Key", systemImage: "key")
            }
        }
    }

    // MARK: - Helpers

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .font(.caption)
                .lineLimit(1)
                .textSelection(.enabled)
        }
    }

    private var maskedKey: String {
        let key = apiKey
        guard key.count > 8 else { return key }
        return String(key.prefix(8)) + "••••••••"
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        appUserID = Purchases.shared.appUserID
        do {
            customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            errorMessage = "Error \((error as NSError).code): \(error.localizedDescription)"
        }
        isLoading = false
    }
}
