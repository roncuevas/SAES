import SwiftUI
import WebViewAMC

extension PersonalDataScreen: View {
    var body: some View {
        content
            .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                self.isRunningPersonalData = tasks.contains { $0 == "personalData" }
            }
            .onAppear {
                WebViewActions.shared.cancelOtherFetchs(id: "personalData")
                WebViewActions.shared.personalData()
                WebViewActions.shared.getProfileImage()
            }
            .refreshable {
                webViewMessageHandler.personalData.clearPersonalData()
                WebViewActions.shared.personalData()
            }
            .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage,
                               webViewManager: WebViewManager.shared)
    }

    @ViewBuilder
    private var content: some View {
        if webViewMessageHandler.personalData.hasPersonalData {
            List {
                Section(Localization.generalData) {
                    CSTextSelectableView(header: Localization.name,
                                     description: webViewMessageHandler.personalData["name"],
                                     image: webViewMessageHandler.profileImage)
                    CSTextSelectableView(header: Localization.studentID,
                                     description: webViewMessageHandler.personalData["studentID"])
                    CSTextSelectableView(header: Localization.campus,
                                     description: webViewMessageHandler.personalData["campus"])
                    CSTextSelectableView(header: Localization.curp,
                                     description: webViewMessageHandler.personalData["curp"])
                    CSTextSelectableView(header: Localization.rfc,
                                     description: webViewMessageHandler.personalData["rfc"])
                    CSTextSelectableView(header: Localization.militaryID,
                                     description: webViewMessageHandler.personalData["militaryID"])
                    CSTextSelectableView(header: Localization.passport,
                                     description: webViewMessageHandler.personalData["passport"])
                    CSTextSelectableView(header: Localization.gender,
                                     description: webViewMessageHandler.personalData["gender"])
                }
                Section(Localization.birth) {
                    CSTextSelectableView(header: Localization.birthDay,
                                     description: webViewMessageHandler.personalData["birthday"])
                    CSTextSelectableView(header: Localization.nationality,
                                     description: webViewMessageHandler.personalData["nationality"])
                    CSTextSelectableView(header: Localization.birthPlace,
                                     description: webViewMessageHandler.personalData["birthPlace"])
                }
                Section(Localization.address) {
                    CSTextSelectableView(header: Localization.street,
                                     description: webViewMessageHandler.personalData["street"])
                    CSTextSelectableView(header: Localization.extNumber,
                                     description: webViewMessageHandler.personalData["extNumber"])
                    CSTextSelectableView(header: Localization.intNumber,
                                     description: webViewMessageHandler.personalData["intNumber"])
                    CSTextSelectableView(header: Localization.neighborhood,
                                     description: webViewMessageHandler.personalData["neighborhood"])
                    CSTextSelectableView(header: Localization.zipCode,
                                     description: webViewMessageHandler.personalData["zipCode"])
                    CSTextSelectableView(header: Localization.state,
                                     description: webViewMessageHandler.personalData["state"])
                    CSTextSelectableView(header: Localization.municipality,
                                     description: webViewMessageHandler.personalData["municipality"])
                    CSTextSelectableView(header: Localization.phone,
                                     description: webViewMessageHandler.personalData["phone"])
                    CSTextSelectableView(header: Localization.mobile,
                                     description: webViewMessageHandler.personalData["mobile"])
                    CSTextSelectableView(header: Localization.email,
                                     description: webViewMessageHandler.personalData["email"])
                    CSTextSelectableView(header: Localization.employed,
                                     description: webViewMessageHandler.personalData["working"])
                    CSTextSelectableView(header: Localization.officePhone,
                                     description: webViewMessageHandler.personalData["officePhone"])
                }
                Section(Localization.educationLevel) {
                    CSTextSelectableView(header: Localization.previousSchool,
                                     description: webViewMessageHandler.personalData["schoolOrigin"])
                    CSTextSelectableView(header: Localization.stateOfPreviousSchool,
                                     description: webViewMessageHandler.personalData["schoolOriginLocation"])
                    CSTextSelectableView(header: Localization.gpaMiddleSchool,
                                     description: webViewMessageHandler.personalData["gpaMiddleSchool"])
                    CSTextSelectableView(header: Localization.gpaHighSchool,
                                     description: webViewMessageHandler.personalData["gpaHighSchool"])
                }
                Section(Localization.parent) {
                    CSTextSelectableView(header: Localization.guardianName,
                                     description: webViewMessageHandler.personalData["guardianName"])
                    CSTextSelectableView(header: Localization.guardianRFC,
                                     description: webViewMessageHandler.personalData["guardianRFC"])
                    CSTextSelectableView(header: Localization.fathersName,
                                     description: webViewMessageHandler.personalData["fathersName"])
                    CSTextSelectableView(header: Localization.mothersName,
                                     description: webViewMessageHandler.personalData["mothersName"])
                }
            }
        } else if isRunningPersonalData {
            SearchingView(title: Localization.searchingForPersonalData)
        } else {
            NoContentView {
                WebViewActions.shared.personalData()
            }
        }
    }
}
