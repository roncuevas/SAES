import SwiftUI
import Routing

struct SchoolSelectionScreen: View {
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
        .navigationBarTitle(
            title: Localization.selectYourSchool,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: true
        )
    }
    
    private func schoolList(schoolType: SchoolType) -> some View {
        List(schoolType.schoolData, id: \.id) { school in
            HStack {
                Image(school.code.getImageName())
                    .resizable()
                    .frame(width: 50, height: 50)
                Button {
                    guard let url = viewModel.getSaesUrl(schoolType: schoolType, schoolCode: school.code) else { return }
                    UserDefaults.standard.set(url, forKey: AppConstants.UserDefaultsKeys.saesURL)
                    UserDefaults.standard.set(school.code.rawValue, forKey: AppConstants.UserDefaultsKeys.schoolCode)
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.isSetted)
                } label: {
                    Text(school.name)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
