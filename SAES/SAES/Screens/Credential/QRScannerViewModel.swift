import Foundation
import VisionKit

@MainActor
final class QRScannerViewModel: ObservableObject {
    @Published var scannedCode: String = ""
    @Published var manualCode: String = ""
    @Published var showManualEntry: Bool = false
    @Published var hasScanned: Bool = false

    var isCameraAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func handleScan(_ code: String) {
        guard !hasScanned else { return }
        hasScanned = true
        scannedCode = code
    }

    func submitManualCode() -> String? {
        let trimmed = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    func reset() {
        scannedCode = ""
        manualCode = ""
        showManualEntry = false
        hasScanned = false
    }
}
