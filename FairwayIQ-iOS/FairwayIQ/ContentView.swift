import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var bagStore: BagStore
    @EnvironmentObject private var locationProvider: LocationProvider

    @State private var selectedHole = DemoCourse.holes[0]
    @State private var targetMode: TargetMode = .green
    @State private var lie: LieCondition = .fairway
    @State private var windIntoPlayerMph = 0.0
    @State private var elevationChangeFeet = 0.0
    @State private var isShowingBag = false

    private var ballLocation: CLLocationCoordinate2D {
        locationProvider.currentLocation ?? selectedHole.tee
    }

    private var target: CLLocationCoordinate2D {
        switch targetMode {
        case .green: return selectedHole.greenCenter
        case .fairway: return selectedHole.fairwayCenter
        }
    }

    private var recommendations: [ClubRecommendation] {
        RecommendationEngine.recommend(
            from: ShotContext(
                ballLocation: ballLocation,
                target: target,
                hole: selectedHole,
                lie: lie,
                windIntoPlayerMph: windIntoPlayerMph,
                elevationChangeFeet: elevationChangeFeet
            ),
            clubs: bagStore.clubs
        )
    }

    var body: some View {
        CaddieMapView(
            selectedHole: $selectedHole,
            targetMode: $targetMode,
            lie: $lie,
            windIntoPlayerMph: $windIntoPlayerMph,
            elevationChangeFeet: $elevationChangeFeet,
            isShowingBag: $isShowingBag,
            ballLocation: ballLocation,
            target: target,
            recommendations: recommendations
        )
        .environmentObject(locationProvider)
        .sheet(isPresented: $isShowingBag) {
            NavigationStack {
                BagView()
                    .navigationTitle("My Bag")
            }
        }
    }
}

enum TargetMode: String, CaseIterable, Identifiable {
    case green = "Green"
    case fairway = "Fairway"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .green: return "GRN"
        case .fairway: return "FWY"
        }
    }
}

private struct CaddieMapView: View {
    @EnvironmentObject private var locationProvider: LocationProvider

    @Binding var selectedHole: Hole
    @Binding var targetMode: TargetMode
    @Binding var lie: LieCondition
    @Binding var windIntoPlayerMph: Double
    @Binding var elevationChangeFeet: Double
    @Binding var isShowingBag: Bool

    var ballLocation: CLLocationCoordinate2D
    var target: CLLocationCoordinate2D
    var recommendations: [ClubRecommendation]

    private var topPick: ClubRecommendation? { recommendations.first }
    private var distanceToTarget: Double { ballLocation.distanceYards(to: target) }
    private var fromTee: Double { selectedHole.tee.distanceYards(to: ballLocation) / 100 }
    private var totalHoleDistance: Double { selectedHole.tee.distanceYards(to: selectedHole.greenCenter) }

    var body: some View {
        ZStack {
            CourseMapView(
                hole: selectedHole,
                ballLocation: ballLocation,
                target: target,
                targetMode: targetMode
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.35),
                    .clear,
                    .clear,
                    .black.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                TopMetrics(
                    distanceToTarget: distanceToTarget,
                    fromTee: fromTee
                )
                .padding(.top, 12)
                .padding(.horizontal, 18)

                Spacer()
            }

            CenterCaddieReadout(
                recommendation: topPick,
                distanceToTarget: distanceToTarget,
                targetMode: targetMode
            )

            HStack(alignment: .bottom) {
                LeftToolRail(
                    isShowingBag: $isShowingBag,
                    requestGPS: locationProvider.requestLocation
                )
                .padding(.leading, 18)
                .padding(.bottom, 52)

                Spacer()

                RightControlRail(
                    targetMode: $targetMode,
                    lie: $lie,
                    windIntoPlayerMph: $windIntoPlayerMph,
                    elevationChangeFeet: $elevationChangeFeet,
                    recommendations: recommendations
                )
                .padding(.trailing, 18)
                .padding(.bottom, 52)
            }

            VStack {
                Spacer()

                BottomHoleBar(
                    selectedHole: $selectedHole,
                    totalHoleDistance: totalHoleDistance
                )
                .padding(.horizontal, 72)
                .padding(.bottom, 18)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedHole) { _, newHole in
            locationProvider.useDemoLocation(newHole.tee)
        }
    }
}

private struct TopMetrics: View {
    var distanceToTarget: Double
    var fromTee: Double

    var body: some View {
        HStack {
            MetricBubble(title: "To Hole", value: "\(Int(distanceToTarget.rounded())) yd")
            Spacer()
            MetricBubble(title: "From Tee", value: String(format: "%.2f", max(0, fromTee)))
        }
    }
}

private struct MetricBubble: View {
    var title: String
    var value: String

    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.78))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 9)
        .background(.black.opacity(0.86))
        .clipShape(Capsule())
    }
}

private struct CenterCaddieReadout: View {
    var recommendation: ClubRecommendation?
    var distanceToTarget: Double
    var targetMode: TargetMode

    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(distanceToTarget.rounded())) yd")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.9), radius: 4, y: 2)

            if let recommendation {
                Text("+ \(String(format: "%.2f", recommendation.confidence)) (\(targetMode.shortLabel))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .shadow(color: .black.opacity(0.9), radius: 3, y: 1)

                HStack(spacing: 8) {
                    MiniBadge(text: recommendation.club.name)
                    MiniBadge(text: "\(Int(recommendation.club.carryYards)) carry")
                }
            }
        }
        .padding(.top, 78)
    }
}

private struct MiniBadge: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.72))
            .clipShape(Capsule())
    }
}

private struct LeftToolRail: View {
    @Binding var isShowingBag: Bool
    var requestGPS: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Button {
                isShowingBag = true
            } label: {
                Image(systemName: "bag.fill")
            }

            Button(action: requestGPS) {
                Image(systemName: "scope")
            }

            Button {
            } label: {
                Image(systemName: "flag")
            }

            Button {
            } label: {
                Image(systemName: "figure.golf")
            }

            Button {
            } label: {
                Image(systemName: "arrow.uturn.left")
            }
        }
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 48)
        .padding(.vertical, 14)
        .background(.black.opacity(0.86))
        .clipShape(Capsule())
        .buttonStyle(.plain)
    }
}

private struct RightControlRail: View {
    @Binding var targetMode: TargetMode
    @Binding var lie: LieCondition
    @Binding var windIntoPlayerMph: Double
    @Binding var elevationChangeFeet: Double
    var recommendations: [ClubRecommendation]

    var body: some View {
        VStack(spacing: 12) {
            WindPill(windIntoPlayerMph: $windIntoPlayerMph)

            VStack(spacing: 0) {
                ForEach(TargetMode.allCases) { mode in
                    Button {
                        targetMode = mode
                    } label: {
                        Text(mode == .green ? "Appr" : "Tee")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(targetMode == mode ? .black : .white)
                            .frame(width: 45, height: 38)
                            .background(targetMode == mode ? .white.opacity(0.92) : .black.opacity(0.86))
                    }
                }
            }
            .clipShape(Capsule())
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                ForEach(recommendations.prefix(4)) { recommendation in
                    Button {
                    } label: {
                        Text(recommendation.club.name)
                            .font(.system(size: 11, weight: .black))
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .frame(width: 45, height: 38)
                            .background(.black.opacity(0.86))
                    }
                }
            }
            .clipShape(Capsule())
            .buttonStyle(.plain)

            Menu {
                Picker("Lie", selection: $lie) {
                    ForEach(LieCondition.allCases) { lie in
                        Text(lie.rawValue).tag(lie)
                    }
                }

                Stepper("Elevation \(Int(elevationChangeFeet)) ft", value: $elevationChangeFeet, in: -80...80, step: 5)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(.black.opacity(0.86))
                    .clipShape(Circle())
            }
        }
    }
}

private struct WindPill: View {
    @Binding var windIntoPlayerMph: Double

    var body: some View {
        Menu {
            Stepper("Wind \(Int(windIntoPlayerMph)) mph", value: $windIntoPlayerMph, in: -25...25, step: 1)
        } label: {
            VStack(spacing: 0) {
                Image(systemName: windIntoPlayerMph >= 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 13, weight: .black))
                Text("\(abs(Int(windIntoPlayerMph))) mph")
                    .font(.system(size: 11, weight: .black))
                Text("Live")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background(.black.opacity(0.86))
            .clipShape(Circle())
        }
    }
}

private struct BottomHoleBar: View {
    @Binding var selectedHole: Hole
    var totalHoleDistance: Double

    var body: some View {
        HStack(spacing: 12) {
            Button {
                moveHole(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .black))
            }

            Spacer()

            Menu {
                Picker("Hole", selection: $selectedHole) {
                    ForEach(DemoCourse.holes) { hole in
                        Text("Hole \(hole.number) - Par \(hole.par)").tag(hole)
                    }
                }
            } label: {
                VStack(spacing: 1) {
                    Text("Hole \(selectedHole.number) - Par \(selectedHole.par)")
                        .font(.system(size: 12, weight: .black))
                    Text("\(Int(totalHoleDistance.rounded())) Yards")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
            }

            Spacer()

            Button {
                moveHole(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .black))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(.black.opacity(0.86))
        .clipShape(Capsule())
        .buttonStyle(.plain)
    }

    private func moveHole(by offset: Int) {
        guard let currentIndex = DemoCourse.holes.firstIndex(where: { $0.id == selectedHole.id }) else { return }
        let newIndex = min(max(currentIndex + offset, 0), DemoCourse.holes.count - 1)
        selectedHole = DemoCourse.holes[newIndex]
    }
}
