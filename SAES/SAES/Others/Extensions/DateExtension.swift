import Foundation

extension Date {
    static func getNextDayOfWeek(_ dayOfWeek: String, startTime: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let startTimeDate = dateFormatter.date(from: startTime) else { return Date() }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: startTimeDate)

        let weekDays: [String: Int] = [
            "domingo": 1,
            "lunes": 2,
            "martes": 3,
            "miércoles": 4,
            "jueves": 5,
            "viernes": 6,
            "sábado": 7
        ]

        guard let weekDay = weekDays[dayOfWeek.lowercased()] else { return Date() }
        components.weekday = weekDay

        let today = Date()
        var nextDate = calendar.nextDate(after: today, matching: components, matchingPolicy: .nextTime)!

        // Si el próximo día encontrado es hoy pero la hora ya pasó, calcula para la próxima semana.
        if calendar.isDate(nextDate, inSameDayAs: today) && nextDate < today {
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextDate)!
        }

        return nextDate
    }
    
    static func getDuration(startTime: String, endTime: String) -> TimeInterval {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            guard let startDateTime = dateFormatter.date(from: startTime),
                  let endDateTime = dateFormatter.date(from: endTime) else {
                      return 0
                  }
            
            return endDateTime.timeIntervalSince(startDateTime)
        }
}

