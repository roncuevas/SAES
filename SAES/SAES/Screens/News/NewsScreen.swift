import Foundation
import SwiftUI

@MainActor
struct NewsScreen {
    @State var statements: IPNStatementModel?
    @Environment(\.openURL) var openURL
}
