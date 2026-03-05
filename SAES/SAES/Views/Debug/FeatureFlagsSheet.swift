@preconcurrency import FirebaseRemoteConfig
import SwiftUI

struct FeatureFlagsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var flags: [(key: String, value: String)] = []

    var body: some View {
        NavigationStack {
            List(flags, id: \.key) { flag in
                HStack {
                    Text(flag.key)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(flag.value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .navigationTitle(Localization.debugFeatureFlags)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                loadFlags()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func loadFlags() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let keys = remoteConfig.allKeys(from: .remote)
            + remoteConfig.allKeys(from: .default)
        let uniqueKeys = Array(Set(keys)).sorted()
        flags = uniqueKeys.map { key in
            let value = remoteConfig.configValue(forKey: key).stringValue ?? ""
            return (key: key, value: value)
        }
    }
}
