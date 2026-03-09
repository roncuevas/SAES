import SwiftUI
@preconcurrency import Inject

@main
struct SAESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @AppStorage(AppConstants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = "system"

    init() {
        syncWidgetDataFromOfflineCache()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(colorScheme)
                .onOpenURL { url in
                    DeepLinkHandler.handle(url)
                }
        }
    }

    private func syncWidgetDataFromOfflineCache() {
        let store = WidgetDataStore.shared
        let allSchools = SchoolsConfiguration.shared.highSchools + SchoolsConfiguration.shared.universities
        for school in allSchools {
            guard let cache = OfflineCacheManager.shared.load(school.code),
                  !cache.schedule.isEmpty else { continue }
            store.saveSchedule(cache.schedule, schoolCode: school.code)
            store.addSchoolToManifest(schoolCode: school.code, schoolName: school.name)
        }
    }

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
