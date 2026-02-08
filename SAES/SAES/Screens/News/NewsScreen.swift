import Foundation
import SwiftUI

struct NewsScreen {
    @State var statements: IPNStatementModel?
    @Environment(\.openURL) var openURL
}
