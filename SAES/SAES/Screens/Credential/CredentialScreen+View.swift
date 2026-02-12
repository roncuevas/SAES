import SwiftUI

extension CredentialScreen: View {
    var body: some View {
        content
            .task {
                viewModel.loadSavedCredential()
                if viewModel.hasCredential {
                    await viewModel.fetchCredentialWebData()
                }
                guard viewModel.personalData.isEmpty else { return }
                await viewModel.fetchStudentData()
                await viewModel.fetchProfilePicture()
            }
            .sheet(isPresented: $viewModel.showScanner) {
                QRScannerScreen { code in
                    Task {
                        await viewModel.processScannedQR(code)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let image = viewModel.exportedImage {
                    ShareSheet(activityItems: [image])
                }
            }
            .toolbar {
                if viewModel.hasCredential {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            renderAndShare()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .enableInjection()
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasCredential {
            credentialContent
        } else {
            emptyState
        }
    }

    private var credentialContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                cardView
                    .padding(.horizontal, 20)

                downloadButton
                    .padding(.horizontal, 20)

                deleteButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
    }

    private var cardView: CredentialCardView {
        CredentialCardView(
            studentName: viewModel.studentName,
            studentID: viewModel.studentID,
            career: viewModel.career,
            schoolName: viewModel.schoolName,
            initials: viewModel.initials,
            qrData: viewModel.credentialModel?.qrData ?? "",
            validityText: viewModel.validityText,
            isEnrolled: viewModel.isEnrolled,
            cctCode: viewModel.cctCode,
            profilePicture: viewModel.profilePicture.flatMap { UIImage(data: $0) }
        )
    }

    private var downloadButton: some View {
        Button {
            renderAndShare()
        } label: {
            Label(Localization.downloadCredential, systemImage: "arrow.down.circle.fill")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(Color.saes)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.deleteCredential()
        } label: {
            Label(Localization.deleteCredential, systemImage: "trash")
                .font(.callout)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "person.text.rectangle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(Localization.noCredentialTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(Localization.noCredentialDescription)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                viewModel.showScanner = true
            } label: {
                Label(Localization.scanCredential, systemImage: "qrcode.viewfinder")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.saes)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func renderAndShare() {
        let renderer = ImageRenderer(content: cardView.frame(width: 350))
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            viewModel.exportCard(image)
        }
    }
}
