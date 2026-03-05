import SwiftUI

struct PersonalDataListContent: View {
    let data: [String: String]
    var profilePicture: Data?
    var onAvatarTap: (() -> Void)?

    var body: some View {
        Section {
            headerCard
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }

        dataSection(icon: "person.text.rectangle", title: Localization.generalData, fields: [
            (Localization.curp, "curp"),
            (Localization.rfc, "rfc"),
            (Localization.gender, "gender"),
            (Localization.militaryID, "militaryID"),
            (Localization.passport, "passport"),
            (Localization.employed, "employed")
        ])

        dataSection(icon: "gift", title: Localization.birth, fields: [
            (Localization.nationality, "nationality"),
            (Localization.birthDay, "birthDay"),
            (Localization.birthPlace, "birthPlace")
        ])

        dataSection(icon: "mappin.circle.fill", title: Localization.address, fields: [
            (Localization.street, "street"),
            (Localization.extNumber, "extNumber"),
            (Localization.intNumber, "intNumber"),
            (Localization.neighborhood, "neighborhood"),
            (Localization.zipCode, "zipCode"),
            (Localization.state, "state"),
            (Localization.municipality, "municipality")
        ])

        dataSection(icon: "phone.fill", title: Localization.contact, fields: [
            (Localization.email, "email"),
            (Localization.mobile, "mobile"),
            (Localization.phone, "phone"),
            (Localization.officePhone, "officePhone")
        ])

        dataSection(icon: "graduationcap.fill", title: Localization.educationLevel, fields: [
            (Localization.previousSchool, "previousSchool"),
            (Localization.stateOfPreviousSchool, "stateOfPreviousSchool"),
            (Localization.gpaMiddleSchool, "gpaMiddleSchool"),
            (Localization.gpaHighSchool, "gpaHighSchool")
        ])

        dataSection(icon: "person.2.fill", title: Localization.parent, fields: [
            (Localization.guardianName, "guardianName"),
            (Localization.guardianRFC, "guardianRFC"),
            (Localization.fathersName, "fathersName"),
            (Localization.mothersName, "mothersName")
        ])
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            avatarView

            Text(data["name"] ?? "")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text("\(Localization.studentID): \(data["studentID"] ?? "")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let campus = data["campus"], !campus.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                    Text(campus)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.saes)
                .clipShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var avatarView: some View {
        Button {
            onAvatarTap?()
        } label: {
            Group {
                if let profilePicture, let image = UIImage(data: profilePicture) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray4))
                }
            }
            .frame(width: 88, height: 88)
            .clipShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(onAvatarTap == nil)
    }

    // MARK: - Data Section

    private func dataSection(icon: String, title: String, fields: [(String, String)]) -> some View {
        let visible = fields.filter { _, key in
            guard let value = data[key] else { return false }
            return !value.replacingOccurrences(of: " ", with: "").isEmpty
        }
        return Section {
            ForEach(Array(visible.enumerated()), id: \.element.0) { _, field in
                CSTextSelectableView(header: field.0, description: data[field.1])
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundStyle(.saes)
            .font(.headline)
        }
        .textCase(nil)
    }
}
