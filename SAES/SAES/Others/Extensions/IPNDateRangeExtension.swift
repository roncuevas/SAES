import Foundation

extension IPNDateRange {
    var formatter: DateFormatter {
        let fixedFormatter = DateFormatter()
        fixedFormatter.dateFormat = "yyyy-MM-dd"
        return fixedFormatter
    }

    var startDate: Date? {
        return formatter.date(from: self.start)
    }

    var endDate: Date? {
        return formatter.date(from: self.end)
    }

    var toDateInterval: DateInterval? {
        guard let startDate,
              let endDate else { return nil }
        return DateInterval(start: startDate, end: endDate)
    }

    var toStringInterval: String {
        guard let startDate,
              let endDate else { return "" }

//        let prettyFormatter = DateFormatter()
//        prettyFormatter.dateFormat = "EEEE, dd MMMM"
//        prettyFormatter.string(from: startDate)

        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.dateTemplate = "EEEE, dd MMMM"
        let formattedInterval = formatter.string(from: startDate, to: endDate)
        return formattedInterval
    }
}
