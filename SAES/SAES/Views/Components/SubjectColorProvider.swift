import SwiftUI

enum SubjectColorProvider {
    private static let palette: [Color] = [
        Color(red: 0.30, green: 0.69, blue: 0.31), // green
        Color(red: 0.94, green: 0.36, blue: 0.34), // coral
        Color(red: 0.25, green: 0.47, blue: 0.85), // blue
        Color(red: 0.80, green: 0.66, blue: 0.20), // amber
        Color(red: 0.61, green: 0.35, blue: 0.71), // purple
        Color(red: 0.96, green: 0.49, blue: 0.16), // orange
        Color(red: 0.15, green: 0.65, blue: 0.60), // teal
        Color(red: 0.91, green: 0.40, blue: 0.60), // pink
    ]

    static func colors(for subjects: [String]) -> [(materia: String, color: Color)] {
        let sorted = subjects.sorted()
        return sorted.enumerated().map { index, materia in
            (materia: materia, color: palette[index % palette.count])
        }
    }

    static func color(for subject: String, in subjects: [String]) -> Color {
        let sorted = subjects.sorted()
        guard let index = sorted.firstIndex(of: subject) else {
            return palette[0]
        }
        return palette[index % palette.count]
    }
}
