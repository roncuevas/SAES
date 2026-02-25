import SwiftUI

struct CredentialCardView: View {
    let studentName: String
    let studentID: String
    let career: String
    let schoolName: String
    let schoolAbbreviation: String
    let initials: String
    let qrData: String
    let validityText: String
    let isEnrolled: Bool
    let validityDate: String?
    let cctCode: String
    let profilePicture: UIImage?
    var showBarcode: Bool = false

    @State private var showURLAlert = false
    @State private var showProfilePicturePreview = false

    var body: some View {
        VStack(spacing: 0) {
            header
            studentInfo
            qrSection
        }
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .profilePicturePreview(image: profilePicture, isPresented: $showProfilePicturePreview)
        .alert(Localization.openURL, isPresented: $showURLAlert) {
            Button(Localization.cancel, role: .cancel) {}
            Button(Localization.visit) {
                if let url = URL(string: qrData) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(qrData)
        }
    }

    private var header: some View {
        HStack {
            Text("IPN - \(schoolAbbreviation)")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Text(Localization.student.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.saes)
    }

    private var studentInfo: some View {
        HStack(alignment: .top, spacing: 14) {
            avatarView
            VStack(alignment: .leading, spacing: 4) {
                Text(studentName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(studentID)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !career.isEmpty {
                    Text(career)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(schoolName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
    }

    private var avatarView: some View {
        Button {
            showProfilePicturePreview = true
        } label: {
            Group {
                if let image = profilePicture {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Text(initials)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.saes.opacity(0.7))
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(profilePicture == nil)
    }

    private var qrSection: some View {
        VStack(spacing: 12) {
            Button {
                if qrData.hasPrefix("http") {
                    showURLAlert = true
                }
            } label: {
                QRCodeGeneratorView(data: qrData, size: 160)
                    .padding(12)
                    .background(Color(.qrBackground))
                    .clipShape(.rect(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(!qrData.hasPrefix("http"))

            if showBarcode {
                BarcodeGeneratorView(data: studentID, height: 44)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.qrBackground))
                    .clipShape(.rect(cornerRadius: 8))
                    .onLongPressGesture {
                        UIPasteboard.general.string = studentID
                    }
            }

            if !validityText.isEmpty {
                VStack(spacing: 4) {
                    Text(validityText)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(isEnrolled ? .green : .red)

                    if isEnrolled, let validityDate {
                        Text(String(format: Localization.validUntilDate, validityDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if !cctCode.isEmpty {
                Text("CCT: \(cctCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.secondarySystemBackground))
    }
}
