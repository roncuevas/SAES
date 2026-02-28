import SwiftUI

struct HomeScholarshipsView: View {
    let scholarships: [IPNScholarship]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(scholarships) { scholarship in
                ScholarshipCardView(scholarship: scholarship)
            }
        }
    }
}
