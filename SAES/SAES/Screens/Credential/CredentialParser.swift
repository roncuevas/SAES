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
        let cdvr = try? body.select(".cdvr").first()?.text()
        let cokElement = try? body.select(".cok").first()
        let isEnrolled: Bool
        if cokElement != nil {
            isEnrolled = true
        } else if let text = cdvr?.uppercased() {
            isEnrolled = !text.contains("NO VIGENTE") && !text.contains("NO INSCRITO")
        } else {
            isEnrolled = false
        }

        let profilePictureSrc = try? body.select("img[src^=data:image]").first()?.attr("src")

        guard let studentName = nombre, !studentName.isEmpty else {
            throw CredentialError.parsingFailed
        }

        return CredentialWebData(
            studentID: boleta ?? "",
            studentName: studentName,
            curp: curp ?? "",
            career: carrera ?? "",
            school: escuela ?? "",
            cctCode: isEnrolled ? (cdvr ?? "") : "",
            isEnrolled: isEnrolled,
            statusText: isEnrolled ? cdvr : cdvr,
            profilePictureBase64: profilePictureSrc
        )
    }
}
