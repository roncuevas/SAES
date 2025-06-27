import SwiftUI

struct NoContentView: View {
    var title: String = Localization.noContentTitle
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var action: () -> Void
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label( title: {
                    Text(title)
                }, icon: {
                    icon
                        .foregroundStyle(.saes)
                        .tint(.saes)
                })
            } description: {
                Text(Localization.noContentDescription)
            } actions: {
                Button(Localization.noContentRetry, action: action)
                    .buttonStyle(.borderedProminent)
            }
        } else {
            Label( title: {
                Text(title)
            }, icon: {
                icon
            })
        }
    }
}
