import SwiftUI

struct SetupView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    
    @StateObject var viewModel: SetupViewModel = .init()
    
    var body: some View {
        VStack {
            Text("Selecciona tu escuela")
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
            List(viewModel.allSchools) { school in
                LazyHStack {
                    if UIImage(named: school.code.rawValue) != nil {
                        Image(school.code.rawValue)
                            .resizable()
                            .frame(width: 50, height: 50)
                    } else {
                        Image("default")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
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
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
