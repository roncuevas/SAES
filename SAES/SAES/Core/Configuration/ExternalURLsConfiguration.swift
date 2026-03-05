import Foundation

struct ExternalURLsConfiguration {
    let webcal: WebcalURLs
    let app: AppURLs
    let api: APIURLs
    let ipn: IPNURLs

    static let shared = ExternalURLsConfiguration(
        webcal: WebcalURLs(
            inPerson: "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhEaeX9yo2IzCtXF7e3JFtL2SOmACjtKtVR0JLwWw0MnZx-BSTirzVm6i_io5cefxs",
            remote: "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhSvIzLpzwBxfL-5Lf8KB84vOp_4HGv_bJ1AJpJEi-tIxEmCieJk8KFOPhlSWdlfRo"
        ),
        app: AppURLs(
            feedbackForm: "https://forms.gle/9GP2Mc74urEP54vz9",
            testFlight: "https://testflight.apple.com/join/chRbe5EF",
            appStoreReview: "https://apps.apple.com/app/id6467482580?action=write-review",
            privacyPolicy: "https://api.roncuevas.com/saes_privacy"
        ),
        api: APIURLs(
            base: "https://api.roncuevas.com",
            scraperJS: "/files/ipn_scrapper.js",
            ipnStatements: "/ipn/statements",
            ipnSchedule: "/ipn/v1/schedule",
            ipnScholarships: "/ipn/v1/scholarships",
            ipnAnnouncements: "/ipn/v1/announcements"
        ),
        ipn: IPNURLs(
            base: "https://www.ipn.mx"
        )
    )

    struct WebcalURLs {
        let inPerson: String
        let remote: String
    }

    struct AppURLs {
        let feedbackForm: String
        let testFlight: String
        let appStoreReview: String
        let privacyPolicy: String
    }

    struct APIURLs {
        let base: String
        let scraperJS: String
        let ipnStatements: String
        let ipnSchedule: String
        let ipnScholarships: String
        let ipnAnnouncements: String
    }

    struct IPNURLs {
        let base: String
    }
}
