import SwiftUI

struct HomeAnnouncementsView: View {
    let announcements: [IPNAnnouncement]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(announcements) { announcement in
                AnnouncementCardView(announcement: announcement)
            }
        }
    }
}
