import Foundation

extension SchoolType {
    var schoolData: [SchoolData] {
        switch self {
        case .highSchool:
            return HighSchoolConstants.allSchoolsData.sorted(by: { $0.order < $1.order })
        case .univeristy:
            return UniversityConstants.allSchoolsData.sorted(by: { $0.name < $1.name })
        }
    }
}
