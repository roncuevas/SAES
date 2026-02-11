import SwiftUI

struct CredentialCardView: View {
    let studentName: String
    let studentID: String
    let career: String
    let schoolName: String
    let initials: String
    let qrData: String
    let validityText: String
    let isEnrolled: Bool
    let profilePicture: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            header
            studentInfo
            qrSection
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    private var header: some View {
        HStack {
            Text("IPN")
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
        .background(Color(.systemBackground))
    }

    private var avatarView: some View {
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

    private var qrSection: some View {
        VStack(spacing: 12) {
            QRCodeGeneratorView(data: qrData, size: 160)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if !validityText.isEmpty {
                HStack(spacing: 6) {
                    Text(Localization.credentialValidity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(validityText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(isEnrolled ? .green : .red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
    }
}
