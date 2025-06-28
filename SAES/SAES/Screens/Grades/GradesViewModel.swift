import Foundation

final class GradesViewModel: ObservableObject {
    @Published var evaluateTeacher: Bool
    @Published var grades: [Grupo]
    private var dataSource: GradesDataSource
    private var parser: GradesParser

    init(dataSource: GradesDataSource = NetworkGradesDataSource()) {
        self.evaluateTeacher = false
        self.grades = []
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

    @MainActor
    private func setGrades(_ grades: [Grupo]) {
        self.grades = grades
    }

    @MainActor
    private func setEvaluateTeachers(_ value: Bool) {
        self.evaluateTeacher = value
    }
}
