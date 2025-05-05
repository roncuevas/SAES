import FirebaseRemoteConfig

final class RemoteConfigManager {
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()

    init() {
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
    }

    func fetchRemoteConfig() {
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                debugPrint("RemoteConfig fetched successfully")
            } else {
                debugPrint("Error al obtener RemoteConfig: \(error?.localizedDescription ?? "desconocido")")
            }
        }
    }
}
