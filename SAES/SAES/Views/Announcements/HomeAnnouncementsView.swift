import SwiftUI

struct HomeAnnouncementsView: View {
    let announcements: [IPNAnnouncement]

    var body: some View {
        if announcements.isEmpty {
            HomeSectionEmptyView(
                icon: "megaphone",
                message: Localization.noActiveAnnouncements
            )
        } else {
            VStack(spacing: 10) {
                ForEach(announcements) { announcement in
                    AnnouncementCardView(announcement: announcement)
                }
            }
        }
    }
}
