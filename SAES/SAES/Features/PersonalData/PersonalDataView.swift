import SwiftUI
import Routing
import WebKit
import WebViewAMC
import Inject

struct PersonalDataView: View {
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @State private var isRunningPersonalData: Bool = false
    @ObserveInjection var forceRedraw
    
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
                    CSTextSelectable(header: Localization.name,
                                     description: webViewMessageHandler.personalData["name"],
                                     image: webViewMessageHandler.profileImage)
                    CSTextSelectable(header: Localization.studentID,
                                     description: webViewMessageHandler.personalData["studentID"])
                    CSTextSelectable(header: Localization.campus,
                                     description: webViewMessageHandler.personalData["campus"])
                    CSTextSelectable(header: Localization.curp,
                                     description: webViewMessageHandler.personalData["curp"])
                    CSTextSelectable(header: Localization.rfc,
                                     description: webViewMessageHandler.personalData["rfc"])
                    CSTextSelectable(header: Localization.militaryID,
                                     description: webViewMessageHandler.personalData["militaryID"])
                    CSTextSelectable(header: Localization.passport,
                                     description: webViewMessageHandler.personalData["passport"])
                    CSTextSelectable(header: Localization.gender,
                                     description: webViewMessageHandler.personalData["gender"])
                }
                Section(Localization.birth) {
                    CSTextSelectable(header: Localization.birthDay,
                                     description: webViewMessageHandler.personalData["birthday"])
                    CSTextSelectable(header: Localization.nationality,
                                     description: webViewMessageHandler.personalData["nationality"])
                    CSTextSelectable(header: Localization.birthPlace,
                                     description: webViewMessageHandler.personalData["birthPlace"])
                }
                Section(Localization.address) {
                    CSTextSelectable(header: Localization.street,
                                     description: webViewMessageHandler.personalData["street"])
                    CSTextSelectable(header: Localization.extNumber,
                                     description: webViewMessageHandler.personalData["extNumber"])
                    CSTextSelectable(header: Localization.intNumber,
                                     description: webViewMessageHandler.personalData["intNumber"])
                    CSTextSelectable(header: Localization.neighborhood,
                                     description: webViewMessageHandler.personalData["neighborhood"])
                    CSTextSelectable(header: Localization.zipCode,
                                     description: webViewMessageHandler.personalData["zipCode"])
                    CSTextSelectable(header: Localization.state,
                                     description: webViewMessageHandler.personalData["state"])
                    CSTextSelectable(header: Localization.municipality,
                                     description: webViewMessageHandler.personalData["municipality"])
                    CSTextSelectable(header: Localization.phone,
                                     description: webViewMessageHandler.personalData["phone"])
                    CSTextSelectable(header: Localization.mobile,
                                     description: webViewMessageHandler.personalData["mobile"])
                    CSTextSelectable(header: Localization.email,
                                     description: webViewMessageHandler.personalData["email"])
                    CSTextSelectable(header: Localization.employed,
                                     description: webViewMessageHandler.personalData["working"])
                    CSTextSelectable(header: Localization.officePhone,
                                     description: webViewMessageHandler.personalData["officePhone"])
                }
                Section(Localization.educationLevel) {
                    CSTextSelectable(header: Localization.previousSchool,
                                     description: webViewMessageHandler.personalData["schoolOrigin"])
                    CSTextSelectable(header: Localization.stateOfPreviousSchool,
                                     description: webViewMessageHandler.personalData["schoolOriginLocation"])
                    CSTextSelectable(header: Localization.gpaMiddleSchool,
                                     description: webViewMessageHandler.personalData["gpaMiddleSchool"])
                    CSTextSelectable(header: Localization.gpaHighSchool,
                                     description: webViewMessageHandler.personalData["gpaHighSchool"])
                }
                Section(Localization.parent) {
                    CSTextSelectable(header: Localization.guardianName,
                                     description: webViewMessageHandler.personalData["guardianName"])
                    CSTextSelectable(header: Localization.guardianRFC,
                                     description: webViewMessageHandler.personalData["guardianRFC"])
                    CSTextSelectable(header: Localization.fathersName,
                                     description: webViewMessageHandler.personalData["fathersName"])
                    CSTextSelectable(header: Localization.mothersName,
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
    
    struct CSTextSelectable: View {
        let header: String
        var description: String?
        var image: UIImage?
        let pasteboard = UIPasteboard.general
        
        var body: some View {
            if let description, !description.replacingOccurrences(of: " ", with: "").isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(header)
                        .fontWeight(.bold)
                    Text(description)
                        .textSelection(.enabled)
                    if let image = image {
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 100)
                            Spacer()
                        }
                    }
                }
                .onTapGesture {
                    pasteboard.string = description
                }
            }
        }
    }
}

extension Localization {
    static let generalData = NSLocalizedString("General Data", comment: "")
    static let name = NSLocalizedString("Name", comment: "")
    static let campus = NSLocalizedString("Campus", comment: "")
    static let curp = NSLocalizedString("CURP", comment: "")
    static let rfc = NSLocalizedString("RFC", comment: "")
    static let militaryID = NSLocalizedString("Military ID", comment: "")
    static let passport = NSLocalizedString("Passport", comment: "")
    static let gender = NSLocalizedString("Gender", comment: "")
    static let address = NSLocalizedString("Address", comment: "")
    static let birth = NSLocalizedString("Birth", comment: "")
    static let birthDay = NSLocalizedString("Birthday", comment: "")
    static let nationality = NSLocalizedString("Nationality", comment: "")
    static let birthPlace = NSLocalizedString("Birth place", comment: "")
    static let street = NSLocalizedString("Street", comment: "")
    static let extNumber = NSLocalizedString("External Number", comment: "")
    static let intNumber = NSLocalizedString("Internal Number", comment: "")
    static let neighborhood = NSLocalizedString("Neighborhood", comment: "")
    static let zipCode = NSLocalizedString("ZIP Code", comment: "")
    static let state = NSLocalizedString("State", comment: "")
    static let municipality = NSLocalizedString("Municipality", comment: "")
    static let phone = NSLocalizedString("Phone", comment: "")
    static let mobile = NSLocalizedString("Mobile phone", comment: "")
    static let email = NSLocalizedString("Email", comment: "")
    static let employed = NSLocalizedString("Employed", comment: "")
    static let officePhone = NSLocalizedString("Office phone", comment: "")
    static let educationLevel = NSLocalizedString("Education Level", comment: "")
    static let previousSchool = NSLocalizedString("Previous school", comment: "")
    static let stateOfPreviousSchool = NSLocalizedString("State of previous school", comment: "")
    static let gpaMiddleSchool = NSLocalizedString("GPA Middle School", comment: "")
    static let gpaHighSchool = NSLocalizedString("GPA High School", comment: "")
    static let parent = NSLocalizedString("Parent/Guardian", comment: "")
    static let guardianName = NSLocalizedString("Guardian Name", comment: "")
    static let guardianRFC = NSLocalizedString("Guardian RFC", comment: "")
    static let fathersName = NSLocalizedString("Father's name", comment: "")
    static let mothersName = NSLocalizedString("Mother's name", comment: "")
    static let searchingForPersonalData = NSLocalizedString("Searching for personal data...", comment: "")
}
