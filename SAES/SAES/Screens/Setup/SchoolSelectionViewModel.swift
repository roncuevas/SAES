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
        async let uniStatuses = ServerStatusService.fetchAllStatuses(for: .univeristy)
        async let hsStatuses = ServerStatusService.fetchAllStatuses(for: .highSchool)

        let (fetchedUni, fetchedHS) = await (apiUniversities, apiHighSchools)

        universities = mergeSchools(local: SchoolType.univeristy.schoolData, api: fetchedUni)
        highSchools = mergeSchools(local: SchoolType.highSchool.schoolData, api: fetchedHS)

        isLoading = false

        let (fetchedUniStatuses, fetchedHSStatuses) = await (uniStatuses, hsStatuses)
        for (code, isOnline) in fetchedUniStatuses {
            statuses[code] = isOnline
        }
        for (code, isOnline) in fetchedHSStatuses {
            statuses[code] = isOnline
        }
    }

    func selectSchool(_ item: SchoolDisplayItem) {
        UserDefaults.standard.set(item.saesURL, forKey: AppConstants.UserDefaultsKeys.saesURL)
        UserDefaults.standard.set(item.schoolCode.rawValue, forKey: AppConstants.UserDefaultsKeys.schoolCode)
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.isSetted)
    }

    private func mergeSchools(
        local: [SchoolData],
        api: [AvailableSchool]
    ) -> [SchoolDisplayItem] {
        let apiByCode = Dictionary(uniqueKeysWithValues: api.compactMap { school -> (String, AvailableSchool)? in
            (school.schoolCode, school)
        })

        let source = api.isEmpty ? local : local.filter { apiByCode[$0.code.rawValue] != nil }

        return source.map { school in
            let abbreviation = apiByCode[school.code.rawValue]?.name ?? school.name

            return SchoolDisplayItem(
                id: school.code.rawValue,
                schoolCode: school.code,
                name: school.longName,
                abbreviation: abbreviation,
                saesURL: school.saes,
                imageName: school.code.getImageName()
            )
        }
    }
}
