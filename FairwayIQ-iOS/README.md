# Fairway IQ

Fairway IQ is a clean SwiftUI iOS app prototype that recommends a golf club from your real distances, four-way dispersion patterns, GPS location, and the course layout around the shot.

## What is included

- GPS-aware yardage using `CoreLocation`
- Hybrid satellite course view using `MapKit`
- Club profile editor for carry, total, left miss, right miss, short miss, and long miss
- Local user profile storage for name, handicap, home course, preferred tees, dominant miss, and notes
- Full club setup data with common club types, major golf brands, model, shaft, loft, distance, and dispersion
- Recommendation engine that adjusts for lie, wind, elevation, distance gap, dispersion, and hazard windows
- Full-screen satellite caddie screen inspired by modern golf GPS apps, with floating yardage pills, vertical shot controls, bottom hole navigation, confidence, aim suggestion, and alternates
- Demo course data so the app works immediately in the simulator

## Data storage

The prototype stores user profile and club data locally in `UserDefaults` through the `AppUserData` model. This keeps the app usable immediately without accounts or cloud setup. For production, this can move to SwiftData plus iCloud sync while keeping the same model structure.

## Open in Xcode

1. Open `FairwayIQ.xcodeproj`.
2. Select the `FairwayIQ` scheme.
3. Choose an iPhone simulator or a connected iPhone.
4. Run the app.

The app targets iOS 17 because it uses the modern SwiftUI `Map` APIs.

## Next production steps

- Replace demo course data with a golf course mapping provider.
- Add shot history import from launch monitor data or manual entry.
- Let users tap the map to move the target and landing zone.
- Add strokes-gained style scoring once enough shot history exists.
- Add Apple Watch glance mode for quick on-course recommendations.
