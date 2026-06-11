import CoreLocation
import Foundation
import SwiftUI

enum ClubCategory: String, CaseIterable, Codable, Identifiable {
    case driver = "Driver"
    case wood = "Wood"
    case hybrid = "Hybrid"
    case iron = "Iron"
    case wedge = "Wedge"
    case putter = "Putter"

    var id: String { rawValue }
}

enum ClubType: String, CaseIterable, Codable, Identifiable {
    case driver = "Driver"
    case twoWood = "2 Wood"
    case threeWood = "3 Wood"
    case fourWood = "4 Wood"
    case fiveWood = "5 Wood"
    case sevenWood = "7 Wood"
    case nineWood = "9 Wood"
    case twoHybrid = "2 Hybrid"
    case threeHybrid = "3 Hybrid"
    case fourHybrid = "4 Hybrid"
    case fiveHybrid = "5 Hybrid"
    case sixHybrid = "6 Hybrid"
    case oneIron = "1 Iron"
    case twoIron = "2 Iron"
    case threeIron = "3 Iron"
    case fourIron = "4 Iron"
    case fiveIron = "5 Iron"
    case sixIron = "6 Iron"
    case sevenIron = "7 Iron"
    case eightIron = "8 Iron"
    case nineIron = "9 Iron"
    case pitchingWedge = "Pitching Wedge"
    case gapWedge = "Gap Wedge"
    case sandWedge = "Sand Wedge"
    case lobWedge = "Lob Wedge"
    case chipper = "Chipper"
    case putter = "Putter"

    var id: String { rawValue }

    var category: ClubCategory {
        switch self {
        case .driver: return .driver
        case .twoWood, .threeWood, .fourWood, .fiveWood, .sevenWood, .nineWood: return .wood
        case .twoHybrid, .threeHybrid, .fourHybrid, .fiveHybrid, .sixHybrid: return .hybrid
        case .oneIron, .twoIron, .threeIron, .fourIron, .fiveIron, .sixIron, .sevenIron, .eightIron, .nineIron: return .iron
        case .pitchingWedge, .gapWedge, .sandWedge, .lobWedge, .chipper: return .wedge
        case .putter: return .putter
        }
    }
}

enum GolfBrand: String, CaseIterable, Codable, Identifiable {
    case callaway = "Callaway"
    case taylormade = "TaylorMade"
    case titleist = "Titleist"
    case ping = "PING"
    case cobra = "Cobra"
    case mizuno = "Mizuno"
    case srixon = "Srixon"
    case cleveland = "Cleveland"
    case wilson = "Wilson"
    case pxg = "PXG"
    case tourEdge = "Tour Edge"
    case benHogan = "Ben Hogan"
    case odyssey = "Odyssey"
    case scottyCameron = "Scotty Cameron"
    case bettinardi = "Bettinardi"
    case evnroll = "Evnroll"
    case labGolf = "L.A.B. Golf"
    case sub70 = "Sub 70"
    case maltby = "Maltby"
    case other = "Other"

    var id: String { rawValue }
}

enum LieCondition: String, CaseIterable, Identifiable {
    case tee = "Tee"
    case fairway = "Fairway"
    case firstCut = "First cut"
    case rough = "Rough"
    case sand = "Sand"

    var id: String { rawValue }

    var distancePenalty: Double {
        switch self {
        case .tee, .fairway: return 0
        case .firstCut: return 0.04
        case .rough: return 0.09
        case .sand: return 0.16
        }
    }
}

enum AimSide: String {
    case left = "Aim left edge"
    case center = "Aim center"
    case right = "Aim right edge"
}

struct Club: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var category: ClubCategory
    var type: ClubType
    var brand: GolfBrand
    var model: String
    var loftDegrees: Double?
    var shaft: String
    var carryYards: Double
    var totalYards: Double
    var leftMissYards: Double
    var rightMissYards: Double
    var shortMissYards: Double
    var longMissYards: Double

    var averageDispersion: Double {
        (leftMissYards + rightMissYards + shortMissYards + longMissYards) / 4
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case type
        case brand
        case model
        case loftDegrees
        case shaft
        case carryYards
        case totalYards
        case leftMissYards
        case rightMissYards
        case shortMissYards
        case longMissYards
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let decodedCategory = try container.decodeIfPresent(ClubCategory.self, forKey: .category)
        type = try container.decodeIfPresent(ClubType.self, forKey: .type) ?? Club.inferredType(
            from: try container.decodeIfPresent(String.self, forKey: .name),
            category: decodedCategory
        )
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? type.rawValue
        category = type.category
        brand = try container.decodeIfPresent(GolfBrand.self, forKey: .brand) ?? .other
        model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
        loftDegrees = try container.decodeIfPresent(Double.self, forKey: .loftDegrees)
        shaft = try container.decodeIfPresent(String.self, forKey: .shaft) ?? ""
        carryYards = try container.decode(Double.self, forKey: .carryYards)
        totalYards = try container.decode(Double.self, forKey: .totalYards)
        leftMissYards = try container.decode(Double.self, forKey: .leftMissYards)
        rightMissYards = try container.decode(Double.self, forKey: .rightMissYards)
        shortMissYards = try container.decode(Double.self, forKey: .shortMissYards)
        longMissYards = try container.decode(Double.self, forKey: .longMissYards)
    }

    private static func inferredType(from name: String?, category: ClubCategory?) -> ClubType {
        let normalized = name?.lowercased() ?? ""
        if let exact = ClubType.allCases.first(where: { $0.rawValue.lowercased() == normalized }) {
            return exact
        }

        if normalized.contains("driver") { return .driver }
        if normalized.contains("3 wood") { return .threeWood }
        if normalized.contains("5 wood") { return .fiveWood }
        if normalized.contains("hybrid") { return .fourHybrid }
        if normalized == "pw" || normalized.contains("pitch") { return .pitchingWedge }
        if normalized == "gw" || normalized.contains("gap") { return .gapWedge }
        if normalized == "sw" || normalized.contains("sand") || normalized == "56" { return .sandWedge }
        if normalized == "lw" || normalized.contains("lob") || normalized == "60" { return .lobWedge }
        if normalized.contains("putter") { return .putter }

        switch category {
        case .driver: return .driver
        case .wood: return .threeWood
        case .hybrid: return .fourHybrid
        case .iron: return .sevenIron
        case .wedge: return .sandWedge
        case .putter: return .putter
        case nil: return .sevenIron
        }
    }

    static let starterBag: [Club] = [
        Club(type: .driver, brand: .titleist, model: "TSR", loftDegrees: 10.5, carryYards: 245, totalYards: 265, leftMissYards: 24, rightMissYards: 32, shortMissYards: 16, longMissYards: 18),
        Club(type: .threeWood, brand: .taylormade, model: "Fairway", loftDegrees: 15, carryYards: 218, totalYards: 235, leftMissYards: 20, rightMissYards: 25, shortMissYards: 14, longMissYards: 15),
        Club(type: .fourHybrid, brand: .ping, model: "Hybrid", loftDegrees: 22, carryYards: 195, totalYards: 205, leftMissYards: 16, rightMissYards: 19, shortMissYards: 11, longMissYards: 12),
        Club(type: .sixIron, brand: .mizuno, model: "Iron", loftDegrees: 28, carryYards: 168, totalYards: 174, leftMissYards: 13, rightMissYards: 15, shortMissYards: 9, longMissYards: 10),
        Club(type: .eightIron, brand: .mizuno, model: "Iron", loftDegrees: 36, carryYards: 142, totalYards: 147, leftMissYards: 10, rightMissYards: 12, shortMissYards: 8, longMissYards: 8),
        Club(type: .pitchingWedge, brand: .cleveland, model: "Wedge", loftDegrees: 46, carryYards: 118, totalYards: 121, leftMissYards: 8, rightMissYards: 9, shortMissYards: 7, longMissYards: 7),
        Club(type: .sandWedge, brand: .cleveland, model: "Wedge", loftDegrees: 56, carryYards: 82, totalYards: 84, leftMissYards: 6, rightMissYards: 7, shortMissYards: 6, longMissYards: 5)
    ]
}

extension Club {
    init(
        type: ClubType,
        brand: GolfBrand = .other,
        model: String = "",
        loftDegrees: Double? = nil,
        shaft: String = "",
        carryYards: Double,
        totalYards: Double,
        leftMissYards: Double,
        rightMissYards: Double,
        shortMissYards: Double,
        longMissYards: Double
    ) {
        self.name = type.rawValue
        self.category = type.category
        self.type = type
        self.brand = brand
        self.model = model
        self.loftDegrees = loftDegrees
        self.shaft = shaft
        self.carryYards = carryYards
        self.totalYards = totalYards
        self.leftMissYards = leftMissYards
        self.rightMissYards = rightMissYards
        self.shortMissYards = shortMissYards
        self.longMissYards = longMissYards
    }
}

struct UserProfile: Codable, Equatable {
    var name: String
    var handicap: Double?
    var homeCourse: String
    var preferredTee: String
    var dominantMiss: String
    var notes: String

    static let empty = UserProfile(
        name: "",
        handicap: nil,
        homeCourse: "",
        preferredTee: "",
        dominantMiss: "",
        notes: ""
    )
}

struct AppUserData: Codable, Equatable {
    var profile: UserProfile
    var clubs: [Club]

    static let starter = AppUserData(profile: .empty, clubs: Club.starterBag)
}

struct Hazard: Identifiable, Equatable {
    enum Kind: String {
        case water = "Water"
        case bunker = "Bunker"
        case trees = "Trees"
        case outOfBounds = "OB"

        var color: Color {
            switch self {
            case .water: return .blue
            case .bunker: return .yellow
            case .trees: return .green
            case .outOfBounds: return .red
            }
        }
    }

    let id = UUID()
    var kind: Kind
    var coordinate: CLLocationCoordinate2D
    var radiusYards: Double
}

struct Hole: Identifiable, Equatable {
    let id: Int
    var number: Int
    var par: Int
    var tee: CLLocationCoordinate2D
    var fairwayCenter: CLLocationCoordinate2D
    var greenCenter: CLLocationCoordinate2D
    var hazards: [Hazard]
}

extension Hole: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ShotContext {
    var ballLocation: CLLocationCoordinate2D
    var target: CLLocationCoordinate2D
    var hole: Hole
    var lie: LieCondition
    var windIntoPlayerMph: Double
    var elevationChangeFeet: Double
}

struct ClubRecommendation: Identifiable {
    let id = UUID()
    var club: Club
    var adjustedDistance: Double
    var distanceGap: Double
    var safetyScore: Double
    var confidence: Double
    var aim: AimSide
    var reason: String
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    func distanceYards(to coordinate: CLLocationCoordinate2D) -> Double {
        let start = CLLocation(latitude: latitude, longitude: longitude)
        let end = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return start.distance(from: end) * 1.09361
    }
}
