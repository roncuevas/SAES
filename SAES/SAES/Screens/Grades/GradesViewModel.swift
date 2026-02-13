import Foundation
import WebViewAMC

final class GradesViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var evaluateTeacher: Bool
    @Published var grades: [Grupo]
    private var evaluationLinks: [EvaluationLink]
    private var gradesDataSource: SAESDataSource
    private var evaluationDataSource: SAESDataSource
    private var sessionProvider: UserSessionProvider
    private let webViewManager: WebViewManager
    private var parser: GradesParser
    private var logger: Logger

    init(gradesDataSource: SAESDataSource = GradesDataSource(),
         evaluationDataSource: SAESDataSource = EvaluationTeachersDataSource(),
         sessionProvider: UserSessionProvider = UserSessionManager.shared,
         webViewManager: WebViewManager = .shared) {
        self.loadingState = .idle
        self.evaluateTeacher = false
        self.grades = []
        self.evaluationLinks = []
        self.gradesDataSource = gradesDataSource
        self.evaluationDataSource = evaluationDataSource
        self.sessionProvider = sessionProvider
        self.webViewManager = webViewManager
        self.parser = GradesParser()
        self.logger = Logger(logLevel: .error)
    }

    func getGrades() async {
        do {
            try await performLoading {
                let data = try await self.gradesDataSource.fetch()
                let gradesParsed = try self.parser.parseGrades(data)
                await self.setGrades(gradesParsed)
            }
        } catch let error as GradesError {
            if error == .evaluateTeachers {
                await setEvaluateTeachers(true)
            }
            logger.log(
                level: .error,
                message: "\(error.localizedDescription)",
                source: "GradesViewModel"
            )
        } catch {
            logger.log(
                level: .error,
                message: "\(error)",
                source: "GradesViewModel"
            )
        }
    }

    func evaluateTeachers() async {
        do {
            let data = try await evaluationDataSource.fetch()
            let links = try parser.parseEvaluationLinks(data)
            await setEvaluationLinks(links)
            let cookies = await sessionProvider.cookiesString()
            for link in links {
                var request = URLRequest(url: link.url)
                request.setValue(cookies, forHTTPHeaderField: AppConstants.HTTPHeaders.cookie)
                await webViewManager.webView.load(request)
                try await Task.sleep(for: .seconds(AppConstants.Timing.gradesRetryDelay))
                try await evaluateTeacher()
                try await Task.sleep(for: .seconds(AppConstants.Timing.gradesSecondRetryDelay))
            }
        } catch {
            logger.log(
                level: .error,
                message: "\(error)",
                source: "GradesViewModel"
            )
        }
    }

    @MainActor
    private func evaluateTeacher() async throws {
        guard let jsCode = ConfigurationLoader.shared.loadJavaScript(from: "evaluate_teacher") else { return }
        try await webViewManager.webView.evaluateJavaScript(jsCode)
    }

    @MainActor
    private func setGrades(_ grades: [Grupo]) {
        self.grades = grades
    }

    @MainActor
    private func setEvaluateTeachers(_ value: Bool) {
        self.evaluateTeacher = value
    }

    @MainActor
    private func setEvaluationLinks(_ value: [EvaluationLink]) {
        self.evaluationLinks = value
    }
}
