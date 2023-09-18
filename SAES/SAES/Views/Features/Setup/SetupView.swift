import SwiftUI

struct SetupView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
        
    var body: some View {
        VStack {
            Text("Select your school")
            List(UniversityConstants.allSchoolsData.sorted(by: { $0.name < $1.name })) { school in
                LazyHStack {
                    if UIImage(named: school.code) != nil {
                        Image(school.code)
                    } else {
                        Image("default")
                    }
                    Button {
                        guard let selected = UniveristyCodes(rawValue: school.code) else { return }
                        guard let url = UniversityConstants.schools[selected]?.saes else { return }
                        saesURL = url
                        schoolCode = school.code
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
