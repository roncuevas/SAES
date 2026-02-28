import SwiftUI

struct HomeSectionHeader<TrailingContent: View>: View {
    let icon: String
    let title: String
    var action: (() -> Void)?
    @ViewBuilder var trailing: () -> TrailingContent

    var body: some View {
        HStack {
            Button {
                action?()
            } label: {
                Label {
                    HStack(spacing: 2) {
                        Text(title)
                        if action != nil {
                            Text("→")
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(.saes)
                }
            }
            .disabled(action == nil)
            Spacer()
            trailing()
        }
    }
}

extension HomeSectionHeader where TrailingContent == EmptyView {
    init(icon: String, title: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.action = action
        self.trailing = { EmptyView() }
    }
}
