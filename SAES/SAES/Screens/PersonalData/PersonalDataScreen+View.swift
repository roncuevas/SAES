import SwiftUI

extension PersonalDataScreen: View {
    var body: some View {
        content
            .appErrorOverlay(isDataLoaded: !viewModel.personalData.isEmpty)
            .profilePicturePreview(imageData: viewModel.profilePicture, isPresented: $showProfilePicturePreview)
            .task {
                guard viewModel.personalData.isEmpty
                else { return }
                await viewModel.getData(refresh: false)
                await viewModel.getProfilePicture()
            }
            .refreshable {
                Task {
                    await viewModel.getData(refresh: true)
                }
            }
    }

    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForPersonalData,
            retryAction: { Task { await viewModel.getData(refresh: true) } }
        ) {
            loadedContent
        }
    }

    private var loadedContent: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    generalDataSection
                    birthSection
                    addressSection
                    contactSection
                    educationSection
                    parentSection
                }
                .padding(16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))

            fabButton
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            avatarView

            Text(viewModel["name"] ?? "")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text("\(Localization.studentID): \(viewModel["studentID"] ?? "")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let campus = viewModel["campus"], !campus.isEmpty {
                Label(campus, systemImage: "building.columns.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.saes)
                    .clipShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var avatarView: some View {
        Button {
            showProfilePicturePreview = true
        } label: {
            Group {
                if let data = viewModel.profilePicture, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray4))
                }
            }
            .frame(width: 88, height: 88)
            .clipShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.profilePicture == nil)
    }

    // MARK: - Sections

    private var generalDataSection: some View {
        sectionCard(icon: "person.text.rectangle", title: Localization.generalData) {
            let fields: [(String, String?)] = [
                (Localization.curp, viewModel["curp"]),
                (Localization.rfc, viewModel["rfc"]),
                (Localization.gender, viewModel["gender"]),
                (Localization.militaryID, viewModel["militaryID"]),
                (Localization.passport, viewModel["passport"]),
                (Localization.employed, viewModel["employed"])
            ]
            dataRows(fields)
        }
    }

    private var birthSection: some View {
        sectionCard(icon: "gift", title: Localization.birth) {
            let fields: [(String, String?)] = [
                (Localization.nationality, viewModel["nationality"]),
                (Localization.birthDay, viewModel["birthDay"]),
                (Localization.birthPlace, viewModel["birthPlace"])
            ]
            dataRows(fields)
        }
    }

    private var addressSection: some View {
        sectionCard(icon: "mappin.circle.fill", title: Localization.address) {
            let fields: [(String, String?)] = [
                (Localization.street, viewModel["street"]),
                (Localization.extNumber, viewModel["extNumber"]),
                (Localization.intNumber, viewModel["intNumber"]),
                (Localization.neighborhood, viewModel["neighborhood"]),
                (Localization.zipCode, viewModel["zipCode"]),
                (Localization.state, viewModel["state"]),
                (Localization.municipality, viewModel["municipality"])
            ]
            dataRows(fields)
        }
    }

    private var contactSection: some View {
        sectionCard(icon: "phone.fill", title: Localization.contact) {
            let fields: [(String, String?)] = [
                (Localization.email, viewModel["email"]),
                (Localization.mobile, viewModel["mobile"]),
                (Localization.phone, viewModel["phone"]),
                (Localization.officePhone, viewModel["officePhone"])
            ]
            dataRows(fields)
        }
    }

    private var educationSection: some View {
        sectionCard(icon: "graduationcap.fill", title: Localization.educationLevel) {
            let fields: [(String, String?)] = [
                (Localization.previousSchool, viewModel["previousSchool"]),
                (Localization.stateOfPreviousSchool, viewModel["stateOfPreviousSchool"]),
                (Localization.gpaMiddleSchool, viewModel["gpaMiddleSchool"]),
                (Localization.gpaHighSchool, viewModel["gpaHighSchool"])
            ]
            dataRows(fields)
        }
    }

    private var parentSection: some View {
        sectionCard(icon: "person.2.fill", title: Localization.parent) {
            let fields: [(String, String?)] = [
                (Localization.guardianName, viewModel["guardianName"]),
                (Localization.guardianRFC, viewModel["guardianRFC"]),
                (Localization.fathersName, viewModel["fathersName"]),
                (Localization.mothersName, viewModel["mothersName"])
            ]
            dataRows(fields)
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            router.navigateTo(AppDestination.credential)
        } label: {
            Image(systemName: "qrcode")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(16)
                .background(Color.saes)
                .clipShape(.circle)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func sectionCard<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.saes)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func dataRows(_ fields: [(String, String?)]) -> some View {
        let visible = fields.filter { _, value in
            guard let value else { return false }
            return !value.replacingOccurrences(of: " ", with: "").isEmpty
        }
        return ForEach(Array(visible.enumerated()), id: \.element.0) { index, field in
            CSTextSelectableView(header: field.0, description: field.1)
            if index < visible.count - 1 {
                Divider()
            }
        }
    }
}
