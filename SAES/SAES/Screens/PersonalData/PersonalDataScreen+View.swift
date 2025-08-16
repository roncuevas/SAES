import SwiftUI
import WebViewAMC

extension PersonalDataScreen: View {
    var body: some View {
        content
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
            .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage,
                               webViewManager: WebViewManager.shared)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle:
            Color.clear
        case .loading:
            SearchingView(title: Localization.searchingForPersonalData)
        case .loaded:
            loadedContent
        default:
            NoContentView {
                Task {
                    await viewModel.getData(refresh: true)
                }
            }
        }
    }

    private var loadedContent: some View {
        List {
            Section(Localization.generalData) {
                CSTextSelectableView(header: Localization.name,
                                     description: viewModel["name"],
                                     image: UIImage(data: viewModel.profilePicture ?? Data()))
                CSTextSelectableView(header: Localization.studentID,
                                     description: viewModel["studentID"])
                CSTextSelectableView(header: Localization.campus,
                                     description: viewModel["campus"])
                CSTextSelectableView(header: Localization.curp,
                                     description: viewModel["curp"])
                CSTextSelectableView(header: Localization.rfc,
                                     description: viewModel["rfc"])
                CSTextSelectableView(header: Localization.militaryID,
                                     description: viewModel["militaryID"])
                CSTextSelectableView(header: Localization.passport,
                                     description: viewModel["passport"])
                CSTextSelectableView(header: Localization.gender,
                                     description: viewModel["gender"])
            }
            Section(Localization.birth) {
                CSTextSelectableView(header: Localization.birthDay,
                                     description: viewModel["birthDay"])
                CSTextSelectableView(header: Localization.nationality,
                                     description: viewModel["nationality"])
                CSTextSelectableView(header: Localization.birthPlace,
                                     description: viewModel["birthPlace"])
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
                CSTextSelectableView(header: Localization.phone,
                                     description: viewModel["phone"])
                CSTextSelectableView(header: Localization.mobile,
                                     description: viewModel["mobile"])
                CSTextSelectableView(header: Localization.email,
                                     description: viewModel["email"])
                CSTextSelectableView(header: Localization.employed,
                                     description: viewModel["employed"])
                CSTextSelectableView(header: Localization.officePhone,
                                     description: viewModel["officePhone"])
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
}
