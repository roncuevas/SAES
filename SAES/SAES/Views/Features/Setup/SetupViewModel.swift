import Foundation

class SetupViewModel: ObservableObject {
    enum SchoolType {
        case highSchool
        case univeristy
    }
    
    @Published var schoolType: SchoolType {
        didSet {
            self.allSchools = getSchoolData(of: self.schoolType)
        }
    }
    @Published var allSchools: [SchoolData] = []
    
    init(schoolType: SchoolType = .highSchool) {
        self.schoolType = schoolType
        self.allSchools = getSchoolData(of: schoolType)
    }
    
    private func getSchoolData(of schoolType: SchoolType) -> [SchoolData] {
        var schoolsArray: [SchoolData] = []
        switch schoolType {
        case .highSchool:
            schoolsArray = HighSchoolConstants.allSchoolsData.sorted(by: { $0.order < $1.order })
        case .univeristy:
            schoolsArray = UniversityConstants.allSchoolsData.sorted(by: { $0.name < $1.name })
        }
        return schoolsArray
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
