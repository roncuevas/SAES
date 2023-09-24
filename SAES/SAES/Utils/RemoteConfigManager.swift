import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager {
    
    static let shared: RemoteConfigManager = .init()
    
    private var remoteConfig: RemoteConfig
    private var settings: RemoteConfigSettings
    
    private init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.settings = RemoteConfigSettings()
    }

    private func setConfig() {
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    func fetchConfig() {
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    print(changed)
                    guard let error else { return }
                    print(error)
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func fetchConfig(completion: @escaping (Bool, Error?) -> Void) {
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    print(changed)
                    completion(changed, error)
                    guard let error else { return }
                    print(error)
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func getValue(for key: String) -> RemoteConfigValue {
        remoteConfig.configValue(forKey: key)
    }
    
    func setDefaultConfig(plist: String? = "remote_config_defaults") {
        remoteConfig.setDefaults(fromPlist: plist)
    }
}
