import SwiftUI

struct HomeScholarshipsView: View, ScholarshipFetcher {
    @State private var response: IPNScholarshipResponse?
    let count: Int

    private var displayedScholarships: [IPNScholarship] {
        Array((response?.data.becas ?? []).prefix(count))
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(displayedScholarships) { scholarship in
                ScholarshipCardView(scholarship: scholarship)
            }
        }
        .task { await loadScholarships() }
    }

    private func loadScholarships() async {
        if response == nil {
            response = await fetchScholarships()
        }
    }
}
