import MapKit
import SwiftUI

struct CourseMapView: View {
    var hole: Hole
    var ballLocation: CLLocationCoordinate2D
    var target: CLLocationCoordinate2D
    var targetMode: TargetMode

    private var cameraPosition: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: hole.fairwayCenter,
                span: MKCoordinateSpan(latitudeDelta: 0.0042, longitudeDelta: 0.0032)
            )
        )
    }

    var body: some View {
        Map(initialPosition: cameraPosition) {
            Annotation("Ball", coordinate: ballLocation) {
                ZStack {
                    Circle()
                        .fill(.black)
                        .frame(width: 22, height: 22)
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                }
            }

            Annotation(targetMode.rawValue, coordinate: target) {
                TargetMarker(targetMode: targetMode)
            }

            MapPolyline(coordinates: [ballLocation, target])
                .stroke(.black.opacity(0.45), lineWidth: 7)

            MapPolyline(coordinates: [ballLocation, target])
                .stroke(.white, style: StrokeStyle(lineWidth: 3, dash: [9, 6], lineCap: .round))

            MapPolyline(coordinates: [hole.tee, hole.fairwayCenter, hole.greenCenter])
                .stroke(.white.opacity(0.42), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))

            ForEach(hole.hazards) { hazard in
                Annotation(hazard.kind.rawValue, coordinate: hazard.coordinate) {
                    ZStack {
                        Circle()
                            .fill(hazard.kind.color.opacity(0.52))
                            .frame(width: max(28, hazard.radiusYards * 1.05), height: max(28, hazard.radiusYards * 1.05))
                        Circle()
                            .stroke(.white.opacity(0.82), lineWidth: 1)
                            .frame(width: max(28, hazard.radiusYards * 1.05), height: max(28, hazard.radiusYards * 1.05))
                        Text(hazard.kind.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .tint(.white)
    }
}

private struct TargetMarker: View {
    var targetMode: TargetMode

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.95), lineWidth: 2)
                .frame(width: targetMode == .green ? 86 : 56, height: targetMode == .green ? 86 : 56)
            Circle()
                .fill(.black)
                .frame(width: 20, height: 20)
            Image(systemName: targetMode == .green ? "flag.fill" : "scope")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.7), radius: 3, y: 2)
    }
}
