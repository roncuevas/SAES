import SwiftUI
import Routing

struct SetupView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @StateObject private var router: Router<NavigationRoute> = .init()
    @StateObject var viewModel: SetupViewModel = SetupViewModel()
    
    var body: some View {
        VStack {
            Text("Selecciona tu escuela")
            schoolsList
            schoolSelector
        }
    }
    
    var schoolSelector: some View {
        HStack(spacing: 16) {
            Button("Medio Superior") {
                viewModel.schoolType = .highSchool
            }
            .buttonStyle(.borderedProminent)
            Button("Superior") {
                viewModel.schoolType = .univeristy
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var schoolsList: some View {
        List(viewModel.getSchoolData(of: viewModel.schoolType)) { school in
            LazyHStack {
                Image(school.code.getImageName())
                    .resizable()
                    .frame(width: 50, height: 50)
                Button {
                    guard let url = viewModel.getSaesUrl(schoolType: viewModel.schoolType, schoolCode: school.code) else { return }
                    saesURL = url
                    schoolCode = school.code.rawValue
                    isSetted = true
                } label: {
                    Text(school.name)
                }
            }
        }
    }
}
