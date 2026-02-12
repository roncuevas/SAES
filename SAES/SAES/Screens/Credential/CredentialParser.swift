import Foundation
import SwiftSoup

struct CredentialParser: SAESParser {
    private let logger = Logger(logLevel: .error)

    func parse(data: Data) throws -> CredentialWebData {
        let document = try convert(data)
        guard let body = document.body() else {
            throw CredentialError.parsingFailed
        }

        let boleta = try? body.select(".boleta").first()?.text()
        let nombre = try? body.select(".nombre").first()?.text()
        let curp = try? body.select(".curp").first()?.text()
        let carrera = try? body.select(".carrera").first()?.text()
        let escuela = try? body.select(".escuela").first()?.text()
        let profilePictureSrc = try? body.select("img[src^=data:image]").first()?.attr("src")

        let cdvr = try? body.select(".cdvr").first()?.text()
        let cctFromFont = try? body.select("font b").first()?.text()

        let cokElement = try? body.select(".cok").first()
        let enrollmentDiv = try? body.select("div[style*=background-color]").first()

        let isEnrolled: Bool
        let cctCode: String

        if cokElement != nil {
            isEnrolled = true
            cctCode = cdvr ?? cctFromFont ?? ""
        } else if let div = enrollmentDiv, let text = try? div.text().uppercased() {
            isEnrolled = text.contains("INSCRIT") && !text.contains("NO INSCRIT")
            cctCode = cdvr ?? cctFromFont ?? ""
        } else if let text = cdvr?.uppercased() {
            isEnrolled = !text.contains("NO VIGENTE") && !text.contains("NO INSCRITO")
            cctCode = isEnrolled ? (cdvr ?? "") : ""
        } else {
            isEnrolled = false
            cctCode = cctFromFont ?? ""
        }

        guard let studentName = nombre, !studentName.isEmpty else {
            throw CredentialError.parsingFailed
        }

        return CredentialWebData(
            studentID: boleta ?? "",
            studentName: studentName,
            curp: curp ?? "",
            career: carrera ?? "",
            school: escuela ?? "",
            cctCode: cctCode,
            isEnrolled: isEnrolled,
            statusText: nil,
            profilePictureBase64: profilePictureSrc
        )
    }
}
