import Foundation

struct SchoolDisplayItem: Identifiable {
    let id: String
    let schoolCode: SchoolCodes
    let name: String
    let abbreviation: String
    let saesURL: String
    let imageName: String
}

@MainActor
final class SchoolSelectionViewModel: ObservableObject {
    @Published var selectedType: SchoolType = .univeristy
    @Published var universities: [SchoolDisplayItem] = []
    @Published var highSchools: [SchoolDisplayItem] = []
    @Published var isLoading = true
    @Published var statuses: [String: Bool?] = [:]

    var currentSchools: [SchoolDisplayItem] {
        selectedType == .univeristy ? universities : highSchools
    }

    func loadSchools() async {
        isLoading = true

        async let apiUniversities = AvailableSchoolsService.fetchSchools(.univeristy)
        async let apiHighSchools = AvailableSchoolsService.fetchSchools(.highSchool)

        let (fetchedUni, fetchedHS) = await (apiUniversities, apiHighSchools)

        universities = mergeSchools(
            local: SchoolType.univeristy.schoolData,
            api: fetchedUni,
            type: .univeristy
        )
        highSchools = mergeSchools(
            local: SchoolType.highSchool.schoolData,
            api: fetchedHS,
            type: .highSchool
        )

        isLoading = false
    }

    func checkStatus(for schoolCode: String) async {
        statuses[schoolCode] = .some(nil)
        let result = await ServerStatusService.fetchStatus(for: schoolCode)
        statuses[schoolCode] = result
    }

    func selectSchool(_ item: SchoolDisplayItem) {
        UserDefaults.standard.set(item.saesURL, forKey: AppConstants.UserDefaultsKeys.saesURL)
        UserDefaults.standard.set(item.schoolCode.rawValue, forKey: AppConstants.UserDefaultsKeys.schoolCode)
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.isSetted)
    }

    private func mergeSchools(
        local: [SchoolData],
        api: [AvailableSchool],
        type: SchoolType
    ) -> [SchoolDisplayItem] {
        let apiByCode = Dictionary(uniqueKeysWithValues: api.compactMap { school -> (String, AvailableSchool)? in
            (school.schoolCode, school)
        })

        return local.map { school in
            let apiSchool = apiByCode[school.code.rawValue]
            return SchoolDisplayItem(
                id: school.code.rawValue,
                schoolCode: school.code,
                name: apiSchool?.name ?? school.name,
                abbreviation: school.name,
                saesURL: school.saes,
                imageName: school.code.getImageName()
            )
        }
    }
}
