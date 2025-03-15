import SwiftUI
import Routing

struct SetupView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedType: SchoolType = .univeristy
    var viewModel: SetupViewModel = SetupViewModel()
    
    var body: some View {
        TabView(selection: $selectedType) {
            schoolList(schoolType: selectedType)
                .tabItem {
                    Label(Localization.university, systemImage: "graduationcap.fill")
                }
                .tag(SchoolType.univeristy)
            schoolList(schoolType: selectedType)
                .tabItem {
                    Label(Localization.highSchool, systemImage: "studentdesk")
                }
                .tag(SchoolType.highSchool)
        }
        .navigationTitle(Localization.selectYourSchool)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    private func schoolList(schoolType: SchoolType) -> some View {
        List(schoolType.schoolData, id: \.id) { school in
            HStack {
                Image(school.code.getImageName())
                    .resizable()
                    .frame(width: 50, height: 50)
                Button {
                    guard let url = viewModel.getSaesUrl(schoolType: schoolType, schoolCode: school.code) else { return }
                    saesURL = url
                    schoolCode = school.code.rawValue
                    isSetted = true
                } label: {
                    Text(school.name)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

extension Localization {
    static let university = NSLocalizedString("University", comment: "")
    static let highSchool = NSLocalizedString("High School", comment: "")
    static let selectYourSchool = NSLocalizedString("Select your school", comment: "")
}
