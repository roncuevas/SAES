import SwiftUI
import VisionKit

extension QRScannerScreen: View {
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Localization.scanCredential)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(Localization.cancel) {
                            dismiss()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.showManualEntry || !viewModel.isCameraAvailable {
            manualEntryView
        } else {
            scannerView
        }
    }

    private var scannerView: some View {
        ZStack {
            DataScannerRepresentable { code in
                viewModel.handleScan(code)
                onQRScanned(code)
                dismiss()
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Text(Localization.scanInstructions)
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 24)

                Button {
                    viewModel.showManualEntry = true
                } label: {
                    Text(Localization.enterManually)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.saes)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var manualEntryView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            if !viewModel.isCameraAvailable {
                Text(Localization.cameraNotAvailable)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            TextField(Localization.enterManually, text: $viewModel.manualCode)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 32)

            Button {
                if let code = viewModel.submitManualCode() {
                    onQRScanned(code)
                    dismiss()
                }
            } label: {
                Text(Localization.saveCredential)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.saes)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .disabled(viewModel.manualCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if viewModel.isCameraAvailable {
                Button {
                    viewModel.showManualEntry = false
                } label: {
                    Label(Localization.scanCredential, systemImage: "qrcode.viewfinder")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(Color.saes)
                        .background(Color.saes.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}
