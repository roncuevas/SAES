@preconcurrency import FirebaseInAppMessaging

extension AppDelegate: @preconcurrency InAppMessagingDisplayDelegate {
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage,
                        with action: InAppMessagingAction) {
        let campaignName = inAppMessage.campaignInfo.campaignName
        Task {
            await AnalyticsManager.shared.logInAppMessageAction(
                campaign: campaignName,
                actionURL: action.actionURL?.absoluteString
            )
        }
        if let url = action.actionURL, url.scheme == "saes" {
            DeepLinkHandler.handle(url)
        }
    }

    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage,
                          dismissType: InAppMessagingDismissType) {}

    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {}

    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {}
}
