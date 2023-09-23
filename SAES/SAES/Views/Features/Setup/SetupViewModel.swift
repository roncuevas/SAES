import Foundation

class SetupViewModel: ObservableObject {
    enum SchoolType {
        case highSchool
        case univeristy
    }
    
    @Published var schoolType: SchoolType = .highSchool
    
    func getSchoolData(of schoolType: SchoolType) -> [SchoolData] {
        switch schoolType {
        case .highSchool:
            return HighSchoolConstants.allSchoolsData.sorted(by: { $0.order < $1.order })
        case .univeristy:
            return UniversityConstants.allSchoolsData.sorted(by: { $0.name < $1.name })
        }
    }
    
    func getSaesUrl(schoolType: SchoolType, schoolCode: SchoolCodes) -> String? {
        switch schoolType {
        case .highSchool:
            return HighSchoolConstants.schools[schoolCode]?.saes
        case .univeristy:
            return UniversityConstants.schools[schoolCode]?.saes
        }
    }
}
