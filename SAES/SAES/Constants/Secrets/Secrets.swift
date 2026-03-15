import Foundation

struct Secrets {
    static let cryptoKey: String = ""
    static var revenueCatAPIKey: String {
        #if DEBUG
        "test_LPrNjxSdRisrGizyABhnPuftUPk"
        #else
        "appl_ezSsmdGCXIkeQKFpAPEXbJAYXOC"
        #endif
    }
}
