@preconcurrency import FirebaseRemoteConfig

final class RemoteConfigManager: @unchecked Sendable {
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    private let logger = Logger(logLevel: .error)

    init() {
        settings.minimumFetchInterval = 300
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
    }

    func fetchRemoteConfig() async {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            if status == .successFetchedFromRemote {
                logger.log(level: .info, message: "RemoteConfig fetched successfully", source: "RemoteConfigManager")
            } else if status == .successUsingPreFetchedData {
                logger.log(level: .info, message: "RemoteConfig using pre-fetched data", source: "RemoteConfigManager")
            }
        } catch {
            logger.log(level: .error, message: "Error al obtener RemoteConfig: \(error.localizedDescription)", source: "RemoteConfigManager")
        }
    }
}
