import Foundation
import SwiftUI

@MainActor
struct NewsScreen {
    @StateObject var viewModel = NewsViewModel()
}
