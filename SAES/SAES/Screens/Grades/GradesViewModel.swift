import Foundation
import WebViewAMC

final class GradesViewModel: ObservableObject {
    @Published var evaluateTeacher: Bool
    @Published var grades: [Grupo]
    private var dataSource: GradesDataSource
    private var parser: GradesParser

    init(dataSource: GradesDataSource = NetworkGradesDataSource()) {
        self.evaluateTeacher = false
        self.grades = []
        self.evaluationLinks = []
        self.dataSource = dataSource
        self.parser = GradesParser()
    }

    func getGrades() async {
        do {
            let data = try await dataSource.fetchGrades()
            let gradesParsed = try parser.parseGrades(data)
            await setGrades(gradesParsed)
        } catch let error as GradesError {
            if error == .evaluateTeachers {
                await setEvaluateTeachers(true)
            }
            Logger(logLevel: .error).log(
                level: .error,
                message: "\(error.localizedDescription)",
                metadata: nil,
                source: "GradesViewModel"
            )
        } catch {
            Logger(logLevel: .error).log(
                level: .error,
                message: "\(error)",
                metadata: nil,
                source: "GradesViewModel"
            )
        }
    }

    func evaluateTeachers() async {
        do {
            let data = try await dataSource.fetchEvaluationTeachers()
            let links = try parser.parseEvaluationLinks(data)
            await setEvaluationLinks(links)
            let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
            for link in links {
                var request = URLRequest(url: link.url)
                request.setValue(cookies, forHTTPHeaderField: "Cookie")
                await WebViewManager.shared.webView.load(request)
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await evaluateTeacher()
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        } catch {
            Logger(logLevel: .error).log(
                level: .error,
                message: "\(error)",
                metadata: nil,
                source: "GradesViewModel"
            )
        }
    }

    @MainActor
    private func evaluateTeacher() async throws {
        try await WebViewManager.shared.webView.evaluateJavaScript(
        """
        (() => {
          // Selecciona la última opción de cada <select>
          document.querySelectorAll('select').forEach(select => {
            select.selectedIndex = select.options.length - 1;
          });

          // Marca todos los checkboxes y dispara el evento change
          document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            cb.checked = true;
            cb.dispatchEvent(new Event('change', { bubbles: true }));
          });

          // Para este botón, busca primero "mainCopy_Aceptar", si no existe prueba con "ctl00_mainCopy_Aceptar"
          const btn =
            document.getElementById('mainCopy_Aceptar') ||
            document.getElementById('ctl00_mainCopy_Aceptar');

          if (btn) btn.click();
        })();
        """)
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
