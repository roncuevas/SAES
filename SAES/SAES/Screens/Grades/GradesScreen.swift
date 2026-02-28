@preconcurrency import FirebaseRemoteConfig
import SwiftUI

@MainActor
struct GradesScreen {
    @EnvironmentObject var webViewMessageHandler: WebViewHandler
    @State var isRunningGrades: Bool = false
    @State var isLoadingScreen: Bool = false
    @State var isPresentingAlert: Bool = false
    @State var collapsedMaterias: Set<String> = []
    @StateObject var viewModel: GradesViewModel = GradesViewModel()
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.teacherEvaluation,
        fallback: true
    ) var teacherEvaluationEnabled
}
