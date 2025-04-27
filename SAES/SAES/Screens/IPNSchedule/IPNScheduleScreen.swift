import Foundation
import SwiftUI
import QuickLook
import Inject

struct IPNScheduleScreen {
    @State var schedule: IPNScheduleResponse = []
    @State var pdfURL: URL?
    @Environment(\.openURL) var openURL
    @ObserveInjection var forceRedraw
    let webcalYes = "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhEaeX9yo2IzCtXF7e3JFtL2SOmACjtKtVR0JLwWw0MnZx-BSTirzVm6i_io5cefxs"
    let webcalNo = "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhSvIzLpzwBxfL-5Lf8KB84vOp_4HGv_bJ1AJpJEi-tIxEmCieJk8KFOPhlSWdlfRo"
}
