@preconcurrency import FirebaseMessaging

extension AppDelegate: @preconcurrency MessagingDelegate {
    private static let messagingLogger = Logger(logLevel: .error)

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard fcmToken != nil else {
            Self.messagingLogger.log(level: .error, message: "FCM token is nil", source: "AppDelegate")
            return
        }
        Self.messagingLogger.log(level: .info, message: "Token registered successfully in Firebase Cloud Messaging", source: "AppDelegate")
    }
}
