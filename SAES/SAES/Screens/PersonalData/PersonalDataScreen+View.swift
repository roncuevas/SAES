import SwiftUI
import WebViewAMC

extension PersonalDataScreen: View {
    var body: some View {
        content
            .task {
                guard viewModel.personalData == nil
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
                                     description: viewModel.personalData?.name,
                                     image: UIImage(data: viewModel.profilePicture ?? Data()))
                CSTextSelectableView(header: Localization.studentID,
                                     description: viewModel.personalData?.studentID)
                CSTextSelectableView(header: Localization.campus,
                                     description: viewModel.personalData?.campus)
                CSTextSelectableView(header: Localization.curp,
                                     description: viewModel.personalData?.curp)
                CSTextSelectableView(header: Localization.rfc,
                                     description: viewModel.personalData?.rfc)
                CSTextSelectableView(header: Localization.militaryID,
                                     description: viewModel.personalData?.militaryID)
                CSTextSelectableView(header: Localization.passport,
                                     description: viewModel.personalData?.passport)
                CSTextSelectableView(header: Localization.gender,
                                     description: viewModel.personalData?.gender)
            }
            Section(Localization.birth) {
                CSTextSelectableView(header: Localization.birthDay,
                                     description: viewModel.personalData?.birthday)
                CSTextSelectableView(header: Localization.nationality,
                                     description: viewModel.personalData?.nationality)
                CSTextSelectableView(header: Localization.birthPlace,
                                     description: viewModel.personalData?.birthPlace)
            }
            Section(Localization.address) {
                CSTextSelectableView(header: Localization.street,
                                     description: viewModel.personalData?.street)
                CSTextSelectableView(header: Localization.extNumber,
                                     description: viewModel.personalData?.extNumber)
                CSTextSelectableView(header: Localization.intNumber,
                                     description: viewModel.personalData?.intNumber)
                CSTextSelectableView(header: Localization.neighborhood,
                                     description: viewModel.personalData?.neighborhood)
                CSTextSelectableView(header: Localization.zipCode,
                                     description: viewModel.personalData?.zipCode)
                CSTextSelectableView(header: Localization.state,
                                     description: viewModel.personalData?.state)
                CSTextSelectableView(header: Localization.municipality,
                                     description: viewModel.personalData?.municipality)
                CSTextSelectableView(header: Localization.phone,
                                     description: viewModel.personalData?.phone)
                CSTextSelectableView(header: Localization.mobile,
                                     description: viewModel.personalData?.mobile)
                CSTextSelectableView(header: Localization.email,
                                     description: viewModel.personalData?.email)
                CSTextSelectableView(header: Localization.employed,
                                     description: viewModel.personalData?.working)
                CSTextSelectableView(header: Localization.officePhone,
                                     description: viewModel.personalData?.officePhone)
            }
            Section(Localization.educationLevel) {
                CSTextSelectableView(header: Localization.previousSchool,
                                     description: viewModel.personalData?.schoolOrigin)
                CSTextSelectableView(header: Localization.stateOfPreviousSchool,
                                     description: viewModel.personalData?.schoolOriginLocation)
                CSTextSelectableView(header: Localization.gpaMiddleSchool,
                                     description: viewModel.personalData?.gpaMiddleSchool)
                CSTextSelectableView(header: Localization.gpaHighSchool,
                                     description: viewModel.personalData?.gpaHighSchool)
            }
            Section(Localization.parent) {
                CSTextSelectableView(header: Localization.guardianName,
                                     description: viewModel.personalData?.guardianName)
                CSTextSelectableView(header: Localization.guardianRFC,
                                     description: viewModel.personalData?.guardianRFC)
                CSTextSelectableView(header: Localization.fathersName,
                                     description: viewModel.personalData?.fathersName)
                CSTextSelectableView(header: Localization.mothersName,
                                     description: viewModel.personalData?.mothersName)
            }
        }
    }
}
