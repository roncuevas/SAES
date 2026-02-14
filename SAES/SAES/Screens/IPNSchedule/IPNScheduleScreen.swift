import Foundation
import SwiftUI
import QuickLook
@preconcurrency import Inject

@MainActor
struct IPNScheduleScreen {
    @State var schedule: IPNScheduleResponse = []
    @State var pdfURL: URL?
    @Environment(\.openURL) var openURL
    @ObserveInjection var forceRedraw
    let webcalYes = URLConstants.webcalInPerson
    let webcalNo = URLConstants.webcalRemote
}
