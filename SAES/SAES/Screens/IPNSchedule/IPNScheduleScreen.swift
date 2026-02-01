import Foundation
import SwiftUI
import QuickLook
import Inject

struct IPNScheduleScreen {
    @State var schedule: IPNScheduleResponse = []
    @State var pdfURL: URL?
    @Environment(\.openURL) var openURL
    @ObserveInjection var forceRedraw
    let webcalYes = URLConstants.webcalInPerson
    let webcalNo = URLConstants.webcalRemote
}
