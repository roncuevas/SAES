import Foundation

final class SetupViewModel {
    func getSaesUrl(schoolType: SchoolType, schoolCode: SchoolCodes) -> String? {
        switch schoolType {
        case .highSchool:
            return HighSchoolConstants.schools[schoolCode]?.saes
        case .univeristy:
            return UniversityConstants.schools[schoolCode]?.saes
        }
    }
}
