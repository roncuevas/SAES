import Foundation

struct ExternalURLsConfiguration: Decodable {
    let webcal: WebcalURLs
    let app: AppURLs
    let api: APIURLs
    let ipn: IPNURLs

    struct WebcalURLs: Decodable {
        let inPerson: String
        let remote: String
    }

    struct AppURLs: Decodable {
        let feedbackForm: String
        let testFlight: String
        let appStoreReview: String
        let privacyPolicy: String
    }

    struct APIURLs: Decodable {
        let base: String
        let scraperJS: String
        let ipnStatements: String
        let ipnSchedule: String
    }

    struct IPNURLs: Decodable {
        let base: String
    }
}
