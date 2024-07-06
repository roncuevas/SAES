import SwiftUI
import Routing

struct SetupView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedType: SchoolType = .univeristy
    @StateObject private var router: Router<NavigationRoutes> = .init()
    var viewModel: SetupViewModel = SetupViewModel()
    
    var body: some View {
        VStack {
            TabView(selection: $selectedType) {
                schoolList(schoolType: selectedType)
                    .tabItem {
                        Label("University", systemImage: "graduationcap.fill")
                    }
                    .tag(SchoolType.univeristy)
                schoolList(schoolType: selectedType)
                    .tabItem {
                        Label("High School", systemImage: "studentdesk")
                    }
                    .tag(SchoolType.highSchool)
            }
        }
        .navigationTitle("Select your school")
        .navigationBarBackButtonHidden()
    }
    
    private func schoolList(schoolType: SchoolType) -> some View {
        List(viewModel.getSchoolData(of: schoolType), id: \.id) { school in
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
