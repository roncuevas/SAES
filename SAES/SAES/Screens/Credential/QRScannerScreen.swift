import SwiftUI

struct QRScannerScreen {
    @StateObject var viewModel = QRScannerViewModel()
    let onQRScanned: (String) -> Void
    @Environment(\.dismiss) var dismiss
}
