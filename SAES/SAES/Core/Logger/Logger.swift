import OSLog
import Logging

struct Logger: LogHandler {
    var logLevel: Logging.Logger.Level = .trace
    private let logger = os.Logger(subsystem: "com.roncuevas.saes-app", category: "Logging")
    var metadata: Logging.Logger.Metadata = [:]
    subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }

    func log(
        level: Logging.Logger.Level,
        message: Logging.Logger.Message,
        metadata: Logging.Logger.Metadata?,
        source: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        switch level {
        case .trace:
            logger.trace("\(message, privacy: .public)")
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .notice:
            logger.notice("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .critical:
            logger.critical("\(message, privacy: .public)")
        }
    }
}
