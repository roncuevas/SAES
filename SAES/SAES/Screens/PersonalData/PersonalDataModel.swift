import Foundation

struct PersonalDataModel: Codable {
    // MARK: General data
    let name: String?
    let studentID: String?
    let campus: String?
    let curp: String?
    let rfc: String?
    let militaryID: String?
    let passport: String?
    let gender: String?

    // MARK: Birth
    let birthday: String?
    let nationality: String?
    let birthPlace: String?

    // MARK: Address
    let street: String?
    let extNumber: String?
    let intNumber: String?
    let neighborhood: String?
    let zipCode: String?
    let state: String?
    let municipality: String?
    let phone: String?
    let mobile: String?
    let email: String?
    let working: String?
    let officePhone: String?

    // MARK: Education level
    let schoolOrigin: String?
    let schoolOriginLocation: String?
    let gpaMiddleSchool: String?
    let gpaHighSchool: String?

    // MARK: Parent
    let guardianName: String?
    let guardianRFC: String?
    let fathersName: String?
    let mothersName: String?
}
