import CoreLocation
import Foundation

enum DemoCourse {
    static let holes: [Hole] = [
        Hole(
            id: 1,
            number: 1,
            par: 4,
            tee: CLLocationCoordinate2D(latitude: 33.83002, longitude: -84.38656),
            fairwayCenter: CLLocationCoordinate2D(latitude: 33.83102, longitude: -84.38610),
            greenCenter: CLLocationCoordinate2D(latitude: 33.83202, longitude: -84.38563),
            hazards: [
                Hazard(kind: .bunker, coordinate: CLLocationCoordinate2D(latitude: 33.83172, longitude: -84.38592), radiusYards: 24),
                Hazard(kind: .trees, coordinate: CLLocationCoordinate2D(latitude: 33.83110, longitude: -84.38656), radiusYards: 30)
            ]
        ),
        Hole(
            id: 2,
            number: 2,
            par: 5,
            tee: CLLocationCoordinate2D(latitude: 33.83240, longitude: -84.38490),
            fairwayCenter: CLLocationCoordinate2D(latitude: 33.83375, longitude: -84.38424),
            greenCenter: CLLocationCoordinate2D(latitude: 33.83504, longitude: -84.38344),
            hazards: [
                Hazard(kind: .water, coordinate: CLLocationCoordinate2D(latitude: 33.83440, longitude: -84.38386), radiusYards: 38),
                Hazard(kind: .bunker, coordinate: CLLocationCoordinate2D(latitude: 33.83490, longitude: -84.38363), radiusYards: 22)
            ]
        ),
        Hole(
            id: 3,
            number: 3,
            par: 3,
            tee: CLLocationCoordinate2D(latitude: 33.83533, longitude: -84.38285),
            fairwayCenter: CLLocationCoordinate2D(latitude: 33.83586, longitude: -84.38256),
            greenCenter: CLLocationCoordinate2D(latitude: 33.83635, longitude: -84.38218),
            hazards: [
                Hazard(kind: .water, coordinate: CLLocationCoordinate2D(latitude: 33.83607, longitude: -84.38243), radiusYards: 26),
                Hazard(kind: .outOfBounds, coordinate: CLLocationCoordinate2D(latitude: 33.83648, longitude: -84.38192), radiusYards: 20)
            ]
        )
    ]
}
