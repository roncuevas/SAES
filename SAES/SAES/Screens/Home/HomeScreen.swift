import Foundation
import SwiftUI
import Routing

struct HomeScreen: View {
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var newsExpanded: Bool = true

    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    Text(Localization.latestNewsIPN)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Image(systemName: "link")
                        .font(.headline)
                        .foregroundStyle(.saes)
                        .clipShape(.circle)
                        .onTapGesture {
                            router.navigate(to: .news)
                        }
                    Spacer()
                }
                NewsView(newsCount: 4, columnsCount: 2)
            }
            .padding(16)
        }
    }
}
