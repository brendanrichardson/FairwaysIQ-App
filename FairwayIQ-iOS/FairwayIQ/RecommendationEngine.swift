import CoreLocation
import Foundation

enum RecommendationEngine {
    static func recommend(from context: ShotContext, clubs: [Club]) -> [ClubRecommendation] {
        let rawDistance = context.ballLocation.distanceYards(to: context.target)
        let adjustedDistance = adjustedTargetDistance(
            rawDistance: rawDistance,
            lie: context.lie,
            windIntoPlayerMph: context.windIntoPlayerMph,
            elevationChangeFeet: context.elevationChangeFeet
        )

        return clubs
            .filter { $0.category != .putter }
            .map { club in
                let gap = abs(club.carryYards - adjustedDistance)
                let hazardRisk = hazardRisk(for: club, context: context)
                let dispersionRisk = min(40, club.averageDispersion) / 40
                let distanceRisk = min(1, gap / max(1, adjustedDistance * 0.22))
                let safetyScore = max(0, 100 - (hazardRisk * 42) - (dispersionRisk * 28) - (distanceRisk * 30))
                let confidence = max(0.05, min(0.98, safetyScore / 100))
                let aim = aimSide(for: club, hazards: context.hole.hazards, target: context.target)
                let reason = reasonText(
                    club: club,
                    adjustedDistance: adjustedDistance,
                    gap: gap,
                    hazardRisk: hazardRisk,
                    lie: context.lie,
                    aim: aim
                )

                return ClubRecommendation(
                    club: club,
                    adjustedDistance: adjustedDistance,
                    distanceGap: gap,
                    safetyScore: safetyScore,
                    confidence: confidence,
                    aim: aim,
                    reason: reason
                )
            }
            .sorted {
                if abs($0.safetyScore - $1.safetyScore) > 5 {
                    return $0.safetyScore > $1.safetyScore
                }
                return $0.distanceGap < $1.distanceGap
            }
    }

    private static func adjustedTargetDistance(
        rawDistance: Double,
        lie: LieCondition,
        windIntoPlayerMph: Double,
        elevationChangeFeet: Double
    ) -> Double {
        let lieAdjustment = rawDistance * lie.distancePenalty
        let windAdjustment = windIntoPlayerMph * 1.1
        let elevationAdjustment = elevationChangeFeet / 3
        return max(1, rawDistance + lieAdjustment + windAdjustment + elevationAdjustment)
    }

    private static func hazardRisk(for club: Club, context: ShotContext) -> Double {
        context.hole.hazards.reduce(0) { partial, hazard in
            let hazardDistance = context.ballLocation.distanceYards(to: hazard.coordinate)
            let carryWindowStart = max(0, club.carryYards - club.shortMissYards)
            let carryWindowEnd = club.totalYards + club.longMissYards
            let isInLandingWindow = hazardDistance >= carryWindowStart && hazardDistance <= carryWindowEnd
            let lateralRisk = (club.leftMissYards + club.rightMissYards) / 2 >= hazard.radiusYards * 0.45
            let kindWeight: Double

            switch hazard.kind {
            case .water, .outOfBounds: kindWeight = 1
            case .trees: kindWeight = 0.75
            case .bunker: kindWeight = 0.55
            }

            return partial + ((isInLandingWindow || lateralRisk) ? kindWeight : 0)
        }
    }

    private static func aimSide(for club: Club, hazards: [Hazard], target: CLLocationCoordinate2D) -> AimSide {
        let leftMiss = club.leftMissYards
        let rightMiss = club.rightMissYards
        let hasPenaltyHazard = hazards.contains { $0.kind == .water || $0.kind == .outOfBounds }

        if hasPenaltyHazard && rightMiss > leftMiss * 1.15 {
            return .left
        }

        if hasPenaltyHazard && leftMiss > rightMiss * 1.15 {
            return .right
        }

        return .center
    }

    private static func reasonText(
        club: Club,
        adjustedDistance: Double,
        gap: Double,
        hazardRisk: Double,
        lie: LieCondition,
        aim: AimSide
    ) -> String {
        let distanceLine = "\(Int(club.carryYards)) carry vs \(Int(adjustedDistance)) adjusted yards"
        let fitLine = gap <= 8 ? "tight distance fit" : "keeps the miss manageable"
        let riskLine = hazardRisk >= 1 ? "avoids the highest penalty window" : "balances distance and dispersion"
        return "\(distanceLine), \(fitLine), \(riskLine) from \(lie.rawValue.lowercased()). \(aim.rawValue)."
    }
}
