import SwiftUI

struct BagView: View {
    @EnvironmentObject private var bagStore: BagStore
    @State private var isShowingProfile = false

    var body: some View {
        List {
            Section {
                Button {
                    isShowingProfile = true
                } label: {
                    ProfileSummary(profile: bagStore.userData.profile)
                }
            } header: {
                Text("Golfer")
            } footer: {
                Text("Your profile and club data are saved locally on this device.")
            }

            Section {
                ForEach($bagStore.userData.clubs) { $club in
                    NavigationLink {
                        ClubEditor(club: $club)
                    } label: {
                        ClubSummaryRow(club: club)
                    }
                }
                .onDelete(perform: bagStore.remove)
            } header: {
                Text("Distances and dispersion")
            } footer: {
                Text("Use real carry numbers. Dispersion is the typical miss window for each club.")
            }
        }
        .sheet(isPresented: $isShowingProfile) {
            NavigationStack {
                ProfileEditor(profile: $bagStore.userData.profile)
                    .navigationTitle("Golfer Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ClubType.allCases) { type in
                        Button(type.rawValue) {
                            bagStore.addClub(type: type)
                        }
                    }
                } label: {
                    Label("Add Club", systemImage: "plus")
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Reset demo data", role: .destructive) {
                        bagStore.resetDemoData()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

private struct ProfileSummary: View {
    var profile: UserProfile

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name.isEmpty ? "Add your profile" : profile.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        let handicap = profile.handicap.map { "HCP \(String(format: "%.1f", $0))" }
        let homeCourse = profile.homeCourse.isEmpty ? nil : profile.homeCourse
        return [handicap, homeCourse].compactMap { $0 }.joined(separator: " - ").isEmpty
            ? "Handicap, home course, tees, and notes"
            : [handicap, homeCourse].compactMap { $0 }.joined(separator: " - ")
    }
}

private struct ProfileEditor: View {
    @Binding var profile: UserProfile

    var body: some View {
        Form {
            Section("Player") {
                TextField("Name", text: $profile.name)
                OptionalNumberStepper(title: "Handicap", value: $profile.handicap, range: -10...54, step: 0.1, unit: "")
            }

            Section("Course preferences") {
                TextField("Home course", text: $profile.homeCourse)
                TextField("Preferred tee", text: $profile.preferredTee)
                TextField("Dominant miss", text: $profile.dominantMiss)
            }

            Section("Notes") {
                TextEditor(text: $profile.notes)
                    .frame(minHeight: 110)
            }
        }
    }
}

private struct ClubSummaryRow: View {
    var club: Club

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(club.name)
                    .font(.headline)
                Text("\(club.brand.rawValue) \(club.model)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(club.carryYards)) carry")
                    .font(.subheadline.weight(.semibold))
                Text("\(Int(club.averageDispersion)) yd avg miss")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ClubEditor: View {
    @Binding var club: Club

    var body: some View {
        Form {
            Section("Club") {
                TextField("Display name", text: $club.name)

                Picker("Type", selection: $club.type) {
                    ForEach(ClubType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                Picker("Brand", selection: $club.brand) {
                    ForEach(GolfBrand.allCases) { brand in
                        Text(brand.rawValue).tag(brand)
                    }
                }

                TextField("Model", text: $club.model)
                TextField("Shaft", text: $club.shaft)
                OptionalNumberStepper(title: "Loft", value: $club.loftDegrees, range: 1...75, step: 0.5, unit: "deg")
            }

            Section("Distance") {
                NumberStepper(title: "Carry", value: $club.carryYards, range: 1...360, unit: "yd")
                NumberStepper(title: "Total", value: $club.totalYards, range: 1...380, unit: "yd")
            }

            Section("Dispersion") {
                NumberStepper(title: "Left miss", value: $club.leftMissYards, range: 0...80, unit: "yd")
                NumberStepper(title: "Right miss", value: $club.rightMissYards, range: 0...80, unit: "yd")
                NumberStepper(title: "Short miss", value: $club.shortMissYards, range: 0...60, unit: "yd")
                NumberStepper(title: "Long miss", value: $club.longMissYards, range: 0...60, unit: "yd")
            }
        }
        .navigationTitle(club.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: club.type) { _, newType in
            club.category = newType.category
            club.name = newType.rawValue
            if club.loftDegrees == nil {
                club.loftDegrees = ClubTemplates.template(for: newType, brand: club.brand).loftDegrees
            }
        }
    }
}

private struct NumberStepper: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var unit: String

    var body: some View {
        Stepper(value: $value, in: range, step: 1) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value)) \(unit)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

private struct OptionalNumberStepper: View {
    var title: String
    @Binding var value: Double?
    var range: ClosedRange<Double>
    var step: Double
    var unit: String

    private var displayValue: String {
        guard let value else { return "Not set" }
        let formatted = step < 1 ? String(format: "%.1f", value) : "\(Int(value))"
        return unit.isEmpty ? formatted : "\(formatted) \(unit)"
    }

    var body: some View {
        HStack {
            Toggle(isOn: isEnabled) {
                Text(title)
            }

            Spacer()

            if value != nil {
                Stepper(value: activeValue, in: range, step: step) {
                    Text(displayValue)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .labelsHidden()
            } else {
                Text(displayValue)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { value != nil },
            set: { isOn in
                value = isOn ? range.lowerBound : nil
            }
        )
    }

    private var activeValue: Binding<Double> {
        Binding(
            get: { value ?? range.lowerBound },
            set: { value = $0 }
        )
    }
}
