import Foundation
import SwiftUI

struct NewsScreen {
    @State var statements: IPNStatementModel?
    @Environment(\.openURL) var openURL
    let statementsURL = "https://api.roncuevas.com/ipn/statements"
}
