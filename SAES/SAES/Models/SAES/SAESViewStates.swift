import Foundation

enum SAESViewStates: String, CaseIterable, Sendable {
    case eventTarget = "__EVENTTARGET"
    case eventArgument = "__EVENTARGUMENT"
    case lastFocus = "__LASTFOCUS"
    case viewState = "__VIEWSTATE"
    case viewStateGenerator = "__VIEWSTATEGENERATOR"
    case eventValidation = "__EVENTVALIDATION"
}
