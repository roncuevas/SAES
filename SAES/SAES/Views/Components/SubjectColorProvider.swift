import SwiftUI

enum SubjectColorProvider {
    static func colors(for subjects: [String]) -> [(materia: String, color: Color)] {
        let sorted = subjects.sorted()
        return sorted.enumerated().map { index, materia in
            (materia: materia, color: Color.subjectPalette[index % Color.subjectPalette.count])
        }
    }

    static func color(for subject: String, in subjects: [String]) -> Color {
        let sorted = subjects.sorted()
        guard let index = sorted.firstIndex(of: subject) else {
            return Color.subjectPalette[0]
        }
        return Color.subjectPalette[index % Color.subjectPalette.count]
    }
}
