import SwiftUI
import Routing

struct SetupView: View {
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
                    UserDefaults.standard.set(url, forKey: "saesURL")
                    UserDefaults.standard.set(school.code.rawValue, forKey: "schoolCode")
                    UserDefaults.standard.set(true, forKey: "isSetted")
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
