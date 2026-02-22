import Foundation

extension IPNScheduleEvent {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var startDate: Date? {
        return Self.dateFormatter.date(from: self.start)
    }

    var endDate: Date? {
        return Self.dateFormatter.date(from: self.end)
    }

    var toDateInterval: DateInterval? {
        guard let startDate,
              let endDate else { return nil }
        return DateInterval(start: startDate, end: endDate)
    }

    private static let intervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.dateTemplate = "EEEE, dd MMMM"
        return formatter
    }()

    var toStringInterval: String {
        guard let startDate,
              let endDate else { return "" }
        return Self.intervalFormatter.string(from: startDate, to: endDate)
    }
}
