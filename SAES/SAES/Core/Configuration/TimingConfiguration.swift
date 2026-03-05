import Foundation

struct TimingConfiguration {
    let webViewTimeout: TimeInterval
    let loginDelay: Double
    let logoutDelay: Double
    let gradesRetryDelay: Double
    let gradesSecondRetryDelay: Double
    let minimalDelay: Double
    let reviewRequestDelay: Double

    static let shared = TimingConfiguration(
        webViewTimeout: 10,
        loginDelay: 4.0,
        logoutDelay: 0.5,
        gradesRetryDelay: 2.0,
        gradesSecondRetryDelay: 1.0,
        minimalDelay: 0.005,
        reviewRequestDelay: 0.005
    )
}
