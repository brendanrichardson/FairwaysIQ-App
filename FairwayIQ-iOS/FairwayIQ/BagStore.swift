import Foundation

final class BagStore: ObservableObject {
    @Published var userData: AppUserData {
        didSet { save() }
    }

    var profile: UserProfile {
        get { userData.profile }
        set { userData.profile = newValue }
    }

    var clubs: [Club] {
        get { userData.clubs }
        set { userData.clubs = newValue }
    }

    private let storageKey = "fairway-iq-user-data"
    private let legacyBagStorageKey = "fairway-iq-bag"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(AppUserData.self, from: data) {
            userData = decoded
        } else if let legacyData = UserDefaults.standard.data(forKey: legacyBagStorageKey),
                  let legacyClubs = try? JSONDecoder().decode([Club].self, from: legacyData) {
            userData = AppUserData(profile: .empty, clubs: legacyClubs)
            save()
        } else {
            userData = .starter
        }
    }

    func updateProfile(_ profile: UserProfile) {
        userData.profile = profile
    }

    func update(_ club: Club) {
        guard let index = userData.clubs.firstIndex(where: { $0.id == club.id }) else { return }
        var updatedClub = club
        updatedClub.category = updatedClub.type.category
        if updatedClub.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updatedClub.name = updatedClub.type.rawValue
        }
        userData.clubs[index] = updatedClub
        sortClubs()
    }

    func addClub(type: ClubType = .sevenIron, brand: GolfBrand = .other) {
        let template = ClubTemplates.template(for: type, brand: brand)
        userData.clubs.append(template)
        sortClubs()
    }

    func remove(at offsets: IndexSet) {
        userData.clubs.remove(atOffsets: offsets)
    }

    func resetDemoData() {
        userData = .starter
    }

    private func sortClubs() {
        userData.clubs.sort { lhs, rhs in
            if lhs.category == .putter { return false }
            if rhs.category == .putter { return true }
            return lhs.totalYards > rhs.totalYards
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(userData) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

enum ClubTemplates {
    static func template(for type: ClubType, brand: GolfBrand) -> Club {
        let carry = defaultCarry(for: type)
        let total = type.category == .wedge || type.category == .putter ? carry + 2 : carry + 8
        let lateralMiss = defaultLateralMiss(for: type)
        let depthMiss = defaultDepthMiss(for: type)

        return Club(
            type: type,
            brand: brand,
            model: "",
            loftDegrees: defaultLoft(for: type),
            carryYards: carry,
            totalYards: total,
            leftMissYards: lateralMiss,
            rightMissYards: lateralMiss,
            shortMissYards: depthMiss,
            longMissYards: depthMiss
        )
    }

    private static func defaultCarry(for type: ClubType) -> Double {
        switch type {
        case .driver: return 245
        case .twoWood: return 232
        case .threeWood: return 218
        case .fourWood: return 210
        case .fiveWood: return 202
        case .sevenWood: return 190
        case .nineWood: return 180
        case .twoHybrid: return 205
        case .threeHybrid: return 195
        case .fourHybrid: return 185
        case .fiveHybrid: return 175
        case .sixHybrid: return 165
        case .oneIron: return 205
        case .twoIron: return 195
        case .threeIron: return 185
        case .fourIron: return 175
        case .fiveIron: return 165
        case .sixIron: return 155
        case .sevenIron: return 145
        case .eightIron: return 135
        case .nineIron: return 125
        case .pitchingWedge: return 115
        case .gapWedge: return 100
        case .sandWedge: return 85
        case .lobWedge: return 65
        case .chipper: return 45
        case .putter: return 10
        }
    }

    private static func defaultLoft(for type: ClubType) -> Double? {
        switch type {
        case .driver: return 10.5
        case .twoWood: return 13
        case .threeWood: return 15
        case .fourWood: return 17
        case .fiveWood: return 19
        case .sevenWood: return 21
        case .nineWood: return 24
        case .twoHybrid: return 17
        case .threeHybrid: return 19
        case .fourHybrid: return 22
        case .fiveHybrid: return 25
        case .sixHybrid: return 28
        case .oneIron: return 16
        case .twoIron: return 18
        case .threeIron: return 21
        case .fourIron: return 24
        case .fiveIron: return 27
        case .sixIron: return 31
        case .sevenIron: return 35
        case .eightIron: return 39
        case .nineIron: return 43
        case .pitchingWedge: return 46
        case .gapWedge: return 50
        case .sandWedge: return 56
        case .lobWedge: return 60
        case .chipper: return 37
        case .putter: return nil
        }
    }

    private static func defaultLateralMiss(for type: ClubType) -> Double {
        switch type.category {
        case .driver: return 30
        case .wood: return 24
        case .hybrid: return 19
        case .iron: return 14
        case .wedge: return 8
        case .putter: return 2
        }
    }

    private static func defaultDepthMiss(for type: ClubType) -> Double {
        switch type.category {
        case .driver: return 18
        case .wood: return 15
        case .hybrid: return 12
        case .iron: return 9
        case .wedge: return 6
        case .putter: return 2
        }
    }
}
