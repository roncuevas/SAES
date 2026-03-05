import Foundation

struct DetectionStringsConfiguration {
    let evaluationRequired: String
    let loggedInCheck: String
    let cookieName: String

    static let shared = DetectionStringsConfiguration(
        evaluationRequired: "evalues a tus PROFESORES",
        loggedInCheck: "IPN-SAES",
        cookieName: ".ASPXFORMSAUTH"
    )
}
