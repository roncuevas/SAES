import SwiftUI

enum WidgetColors {
    static let palette: [Color] = [
        Color(.subjectGreen),
        Color(.subjectCoral),
        Color(.subjectBlue),
        Color(.subjectAmber),
        Color(.subjectPurple),
        Color(.subjectOrange),
        Color(.subjectTeal),
        Color(.subjectPink),
    ]

    static func color(at index: Int) -> Color {
        palette[index % palette.count]
    }
}
