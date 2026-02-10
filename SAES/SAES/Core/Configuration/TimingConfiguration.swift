import Foundation

struct TimingConfiguration: Decodable {
    let webViewTimeout: TimeInterval
    let loginDelay: Double
    let logoutDelay: Double
    let gradesRetryDelay: Double
    let gradesSecondRetryDelay: Double
    let minimalDelay: Double
    let reviewRequestDelay: Double
}
