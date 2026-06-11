# Fairway IQ Expo

This is the Windows-friendly Expo React Native version of Fairway IQ. You can run it on your iPhone with Expo Go without owning a Mac.

## Run from Windows

1. Install Node.js from https://nodejs.org/
2. Install Expo Go on your iPhone from the App Store.
3. Open PowerShell in this folder.
4. Run:

```powershell
npm install
npx expo start
```

5. Scan the QR code with Expo Go.

If your phone and PC are not on the same Wi-Fi, press `s` in the Expo terminal to switch connection mode, or use Expo's tunnel option:

```powershell
npx expo start --tunnel
```

## What is included

- Full-screen satellite golf GPS interface
- GPS location through `expo-location`
- Harry L. Jones Sr. / Renaissance Park Golf Course 18-hole map data
- Shot line, target marker, top yardage pills, side controls, and bottom hole selector
- Pinch-to-zoom and drag/pan map gestures
- Tap-to-target and draggable target marker for choosing the intended landing spot
- Dispersion pattern overlay that moves with the selected shot target and selected club
- Local user profile and club storage through AsyncStorage
- Common club types and major golf brands
- Club recommendation logic using carry distance, dispersion, lie, wind, elevation, and hazards

## Course data

The course is mapped in public OpenStreetMap data as `Renaissance Park Golf Course`, 1525 West Tyvola Road, Charlotte, NC 28217. Fairway IQ uses OSM hole geometry for tee-to-green GPS coordinates and approximate mapped hole distances.

The public OSM hole geometry totals about 6,305 mapped yards, so treat the per-hole coordinates/distances as a strong starting layer, not a certified scorecard. Official tee-specific yardages were not available in the public map data used here. A production version should verify every tee box and green on-site or against an official course scorecard/GIS feed.

## Production notes

A production version should connect to a golf course map/layout provider, add tap-to-target map controls, add hazards from mapped course features, and eventually use Expo Application Services for App Store builds.
