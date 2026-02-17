import SwiftUI

extension PersonalDataScreen: View {
    var body: some View {
        content
            .appErrorOverlay(isDataLoaded: !viewModel.personalData.isEmpty)
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
        List {
            Section {
                headerCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section(Localization.generalData) {
                CSTextSelectableView(header: Localization.curp,
                                     description: viewModel["curp"])
                CSTextSelectableView(header: Localization.rfc,
                                     description: viewModel["rfc"])
                CSTextSelectableView(header: Localization.birthDay,
                                     description: viewModel["birthDay"])
                CSTextSelectableView(header: Localization.nationality,
                                     description: viewModel["nationality"])
                CSTextSelectableView(header: Localization.birthPlace,
                                     description: viewModel["birthPlace"])
                CSTextSelectableView(header: Localization.gender,
                                     description: viewModel["gender"])
                CSTextSelectableView(header: Localization.militaryID,
                                     description: viewModel["militaryID"])
                CSTextSelectableView(header: Localization.passport,
                                     description: viewModel["passport"])
                CSTextSelectableView(header: Localization.employed,
                                     description: viewModel["employed"])
            }
            Section(Localization.contact) {
                CSTextSelectableView(header: Localization.email,
                                     description: viewModel["email"])
                CSTextSelectableView(header: Localization.mobile,
                                     description: viewModel["mobile"])
                CSTextSelectableView(header: Localization.phone,
                                     description: viewModel["phone"])
                CSTextSelectableView(header: Localization.officePhone,
                                     description: viewModel["officePhone"])
            }
            Section(Localization.address) {
                CSTextSelectableView(header: Localization.street,
                                     description: viewModel["street"])
                CSTextSelectableView(header: Localization.extNumber,
                                     description: viewModel["extNumber"])
                CSTextSelectableView(header: Localization.intNumber,
                                     description: viewModel["intNumber"])
                CSTextSelectableView(header: Localization.neighborhood,
                                     description: viewModel["neighborhood"])
                CSTextSelectableView(header: Localization.zipCode,
                                     description: viewModel["zipCode"])
                CSTextSelectableView(header: Localization.state,
                                     description: viewModel["state"])
                CSTextSelectableView(header: Localization.municipality,
                                     description: viewModel["municipality"])
            }
            Section(Localization.educationLevel) {
                CSTextSelectableView(header: Localization.previousSchool,
                                     description: viewModel["previousSchool"])
                CSTextSelectableView(header: Localization.stateOfPreviousSchool,
                                     description: viewModel["stateOfPreviousSchool"])
                CSTextSelectableView(header: Localization.gpaMiddleSchool,
                                     description: viewModel["gpaMiddleSchool"])
                CSTextSelectableView(header: Localization.gpaHighSchool,
                                     description: viewModel["gpaHighSchool"])
            }
            Section(Localization.parent) {
                CSTextSelectableView(header: Localization.guardianName,
                                     description: viewModel["guardianName"])
                CSTextSelectableView(header: Localization.guardianRFC,
                                     description: viewModel["guardianRFC"])
                CSTextSelectableView(header: Localization.fathersName,
                                     description: viewModel["fathersName"])
                CSTextSelectableView(header: Localization.mothersName,
                                     description: viewModel["mothersName"])
            }
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            avatarView
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel["name"] ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                Text(viewModel["studentID"] ?? "")
                    .font(.subheadline)
                Text(viewModel["campus"] ?? "")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.saes)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var avatarView: some View {
        Group {
            if let data = viewModel.profilePicture, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Text(initials)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.25))
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }

    private var initials: String {
        let name = viewModel["name"] ?? ""
        let components = name.split(separator: " ")
        let letters = components.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
