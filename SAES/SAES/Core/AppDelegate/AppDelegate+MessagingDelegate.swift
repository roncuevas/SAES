import FirebaseMessaging

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else {
            debugPrint("Error: FCM token is nil")
            return
        }
        debugPrint("Token registered successfully in Firebase Cloud Messaging")
    }
}
