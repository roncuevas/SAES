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
                await viewModel.getData(refresh: true)
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
            dataList
            fabButton
        }
    }

    @ViewBuilder
    private var dataList: some View {
        if #available(iOS 17, *) {
            listContent
                .listSectionSpacing(8)
        } else {
            listContent
        }
    }

    private var listContent: some View {
        List {
            Section {
                headerCard
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            dataSection(icon: "person.text.rectangle", title: Localization.generalData, fields: [
                (Localization.curp, viewModel["curp"]),
                (Localization.rfc, viewModel["rfc"]),
                (Localization.gender, viewModel["gender"]),
                (Localization.militaryID, viewModel["militaryID"]),
                (Localization.passport, viewModel["passport"]),
                (Localization.employed, viewModel["employed"])
            ])

            dataSection(icon: "gift", title: Localization.birth, fields: [
                (Localization.nationality, viewModel["nationality"]),
                (Localization.birthDay, viewModel["birthDay"]),
                (Localization.birthPlace, viewModel["birthPlace"])
            ])

            dataSection(icon: "mappin.circle.fill", title: Localization.address, fields: [
                (Localization.street, viewModel["street"]),
                (Localization.extNumber, viewModel["extNumber"]),
                (Localization.intNumber, viewModel["intNumber"]),
                (Localization.neighborhood, viewModel["neighborhood"]),
                (Localization.zipCode, viewModel["zipCode"]),
                (Localization.state, viewModel["state"]),
                (Localization.municipality, viewModel["municipality"])
            ])

            dataSection(icon: "phone.fill", title: Localization.contact, fields: [
                (Localization.email, viewModel["email"]),
                (Localization.mobile, viewModel["mobile"]),
                (Localization.phone, viewModel["phone"]),
                (Localization.officePhone, viewModel["officePhone"])
            ])

            dataSection(icon: "graduationcap.fill", title: Localization.educationLevel, fields: [
                (Localization.previousSchool, viewModel["previousSchool"]),
                (Localization.stateOfPreviousSchool, viewModel["stateOfPreviousSchool"]),
                (Localization.gpaMiddleSchool, viewModel["gpaMiddleSchool"]),
                (Localization.gpaHighSchool, viewModel["gpaHighSchool"])
            ])

            dataSection(icon: "person.2.fill", title: Localization.parent, fields: [
                (Localization.guardianName, viewModel["guardianName"]),
                (Localization.guardianRFC, viewModel["guardianRFC"]),
                (Localization.fathersName, viewModel["fathersName"]),
                (Localization.mothersName, viewModel["mothersName"])
            ])
        }
        .listStyle(.insetGrouped)
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
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                    Text(campus)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.saes)
                .clipShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            router.navigateTo(AppDestination.credential)
        } label: {
            Image(systemName: "qrcode")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(16)
                .background(.saes)
                .clipShape(.circle)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func dataSection(icon: String, title: String, fields: [(String, String?)]) -> some View {
        let visible = fields.filter { _, value in
            guard let value else { return false }
            return !value.replacingOccurrences(of: " ", with: "").isEmpty
        }
        return Section {
            ForEach(Array(visible.enumerated()), id: \.element.0) { _, field in
                CSTextSelectableView(header: field.0, description: field.1)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundStyle(.saes)
            .font(.headline)
        }
        .textCase(nil)
    }
}
