import FirebaseRemoteConfig

final class RemoteConfigManager {
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()

    init() {
        settings.minimumFetchInterval = 300
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
    }

    func fetchRemoteConfig() {
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote {
                debugPrint("RemoteConfig fetched successfully")
            } else if status == .successUsingPreFetchedData {
                debugPrint("RemoteConfig using pre-fetched data")
            } else {
                debugPrint("Error al obtener RemoteConfig: \(error?.localizedDescription ?? "desconocido")")
            }
        }
    }
}
