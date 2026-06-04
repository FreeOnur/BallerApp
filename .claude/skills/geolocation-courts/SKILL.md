---
name: geolocation-courts
description: Wraps GPS via `baller_app/lib/services/load_position.dart` (`LocationService.loadPosition`, geolocator permission flow) and platform keys in `Info.plist` / `AndroidManifest.xml`, then wires position into map pages for nearby court sorting. Use when the user says 'get location', 'nearby courts', 'sort by distance', 'map permissions', 'user position', or edits `load_position.dart`, `map_page.dart`, or `map_selection_page.dart`. Key capabilities: service-enabled checks, denied/deniedForever handling, `Geolocator.distanceBetween` sorting, and iOS/Android permission strings. Do NOT call `Geolocator` directly from widgets for permission or `getCurrentPosition`; do NOT use for Supabase SQL, edge functions, `court_services.dart` refactors, or new `Court` model fields (use `supabase-service` / `court-model`).
paths:
  - baller_app/lib/services/load_position.dart
  - baller_app/lib/pages/Map/**
  - baller_app/ios/Runner/Info.plist
  - baller_app/android/app/src/main/AndroidManifest.xml
  - baller_app/pubspec.yaml
---
# Geolocation Courts

## Critical

- **Never call `Geolocator` directly from UI pages** for `checkPermission`, `requestPermission`, or `getCurrentPosition`. All GPS access goes through `LocationService` in `baller_app/lib/services/load_position.dart`.
- `loadPosition()` returns `Future<Position?>` — `null` means location services off, permission denied/deniedForever, or failure. UI must not force-unwrap `userPosition!` except after an explicit `userPosition != null` guard.
- Nearby courts use **client-side** distance via `Geolocator.distanceBetween` in `baller_app/lib/pages/Map/map_page.dart`; court rows still load from Supabase (`fetchCourts` inline query). Do not add PostGIS/radius SQL in this skill.
- Before device testing, confirm platform keys exist:
  - iOS: `baller_app/ios/Runner/Info.plist` — `NSLocationWhenInUseUsageDescription`
  - Android: `baller_app/android/app/src/main/AndroidManifest.xml` — `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`
- Dependency is already in `baller_app/pubspec.yaml`: `geolocator: ^14.0.2`. Do not add a second location package.
- Run validation from `baller_app/`: `flutter analyze lib/services/load_position.dart lib/pages/Map`

## Instructions

1. **Confirm platform permissions before changing Dart**
   - iOS (`baller_app/ios/Runner/Info.plist`): ensure **one** `NSLocationWhenInUseUsageDescription` with user-facing copy (repo currently has duplicate keys — dedupe to a single string, e.g. `Wir brauchen deinen Standort, um Courts in deiner Nähe anzuzeigen.`). Add `NSLocationAlwaysAndWhenInUseUsageDescription` / `UIBackgroundModes` → `location` only if product requires background tracking.
   - Android (`baller_app/android/app/src/main/AndroidManifest.xml`): ensure these appear **once** under `<manifest>` (file currently duplicates them — remove extras):
     ```xml
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
     ```
   - **Verify:** `grep -E "NSLocationWhenInUse|ACCESS_FINE" baller_app/ios/Runner/Info.plist baller_app/android/app/src/main/AndroidManifest.xml` shows the keys before proceeding.
   - This step uses no prior output.

2. **Use or extend `LocationService` — do not duplicate permission logic**
   - File: `baller_app/lib/services/load_position.dart`
   - Keep imports:
     ```dart
     import 'package:geolocator/geolocator.dart';
     import 'package:flutter/foundation.dart';
     ```
   - Preserve the existing flow (match unless adding product behavior):
     ```dart
     class LocationService {
       Future<Position?> loadPosition() async {
         bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
         if (!serviceEnabled) {
           debugPrint("❌ Location Service off");
           return null;
         }

         LocationPermission permission = await Geolocator.checkPermission();

         if (permission == LocationPermission.denied) {
           permission = await Geolocator.requestPermission();
         }

         if (permission == LocationPermission.deniedForever) {
           debugPrint("❌ Permission denied forever");
           return null;
         }

         return await Geolocator.getCurrentPosition(
           desiredAccuracy: LocationAccuracy.high,
         );
       }
     }
     ```
   - If you need settings redirect for `deniedForever`, add `await Geolocator.openAppSettings()` **inside** `LocationService`, not in widgets.
   - **Verify:** `cd baller_app && flutter analyze lib/services/load_position.dart` passes before proceeding.
   - This step uses platform keys from Step 1.

3. **Wire location into a map page using existing field patterns**
   - Import: `import 'package:baller_app/services/load_position.dart';`
   - For distance math on courts, also: `import 'package:geolocator/geolocator.dart';`
   - State fields (from `map_page.dart` / `map_selection_page.dart`):
     ```dart
     final LocationService locationService = LocationService();
     Position? userPosition;
     ```
   - In `initState()`, call a page-local async method (do not `await` inside `initState`):
     ```dart
     @override
     void initState() {
       super.initState();
       loadPosition();
     }
     ```
   - Load method — use the **instance** field (`map_selection_page.dart` pattern):
     ```dart
     Future<void> loadPosition() async {
       userPosition = await locationService.loadPosition();
       setState(() {});
     }
     ```
   - `map_page.dart` currently calls `LocationService().loadPosition()` in `loadPosition()` despite having `locationService`; **new/edited code** should use `locationService.loadPosition()` and call `updateSortedCourts()` after assign.
   - **Verify:** no `userPosition!` without a preceding `if (userPosition != null)` guard before proceeding.
   - This step uses `LocationService` from Step 2.

4. **Handle `null` position in UI (required patterns)**
   - **Blocking UI** (`map_selection_page.dart`): while `userPosition == null`, show loading:
     ```dart
     if (userPosition == null) {
       return const Scaffold(
         body: Center(child: CircularProgressIndicator()),
       );
     }
     ```
   - **Non-blocking UI** (`map_page.dart`): keep rendering courts; gate distance labels:
     ```dart
     if (userPosition != null)
       Text(
         "${(distanceToCourt(court) / 1000).toStringAsFixed(1)} km entfernt",
         ...,
       );
     ```
   - Camera animation: only when **both** `mapController != null` and `userPosition != null` (see `_moveCameraToUser()` in `map_selection_page.dart`):
     ```dart
     if (mapController != null && userPosition != null) {
       mapController!.animateCamera(
         CameraUpdate.newLatLngZoom(
           LatLng(userPosition!.latitude, userPosition!.longitude),
           13,
         ),
       );
     }
     ```
   - **Verify:** app does not crash when permission is denied (lists still load) before proceeding.
   - This step uses `userPosition` from Step 3.

5. **Sort courts by proximity (nearby courts)**
   - Reuse `map_page.dart` helpers; do not query Supabase by lat/lng for sorting:
     ```dart
     double distanceToCourt(Court court) {
       if (userPosition == null) return double.infinity;
       return Geolocator.distanceBetween(
         userPosition!.latitude,
         userPosition!.longitude,
         court.lat,
         court.lng,
       );
     }

     void updateSortedCourts() {
       if (userPosition == null) {
         sortedCourts = List.from(filteredCourts);
         return;
       }
       sortedCourts = List<Court>.from(filteredCourts)
         ..sort((a, b) => distanceToCourt(a).compareTo(distanceToCourt(b)));
     }
     ```
   - Call `updateSortedCourts()` after `loadPosition()` completes and after `searchCourts()` / filter changes.
   - Google Map: keep `myLocationEnabled: true` on `GoogleMap` when fine location is granted (existing `map_page.dart`).
   - **Verify:** with location granted, list shows `X.X km entfernt`; with location denied, courts still appear without distance labels.
   - This step uses `userPosition` from Step 3 and court list from existing `fetchCourts()`.

6. **Run project validation**
   - From `baller_app/`:
     ```bash
     dart format lib/services/load_position.dart lib/pages/Map
     flutter analyze lib/services/load_position.dart lib/pages/Map
     ```
   - On device: deny permission once, reopen map — confirm no red screen / null crash.
   - **Verify:** `flutter analyze` reports no errors in touched files.
   - This step uses all files from Steps 1–5.

## Examples

### Example 1: Show nearby courts sorted by distance on the map page

**User says:** "Sort courts by how close they are to me on the map."

**Actions taken:**
1. Confirm `NSLocationWhenInUseUsageDescription` in `baller_app/ios/Runner/Info.plist` and `ACCESS_FINE_LOCATION` in `baller_app/android/app/src/main/AndroidManifest.xml` (dedupe duplicates).
2. Leave `LocationService.loadPosition()` in `baller_app/lib/services/load_position.dart` unchanged unless permission UX needs `openAppSettings()`.
3. In `baller_app/lib/pages/Map/map_page.dart`:
   - Imports: `package:baller_app/services/load_position.dart`, `package:geolocator/geolocator.dart`.
   - `Position? userPosition`, `final LocationService locationService = LocationService();`.
   - `initState()` calls `loadPosition()` and `fetchCourts()`.
   - `loadPosition()` → `userPosition = await locationService.loadPosition();` → `updateSortedCourts();` → guarded camera → `setState()`.
   - Keep `distanceToCourt` / `updateSortedCourts` / `if (userPosition != null)` distance label (~line 262).
4. Run `cd baller_app && flutter analyze lib/pages/Map`.

**Result:** Approved courts load from Supabase; when GPS succeeds, list order and `km entfernt` labels reflect distance. When GPS fails, courts still display without crashing.

### Example 2: New screen that centers the map on the user

**User says:** "Add a page to pick a court location starting at my GPS position."

**Actions taken:**
1. Mirror `baller_app/lib/pages/Map/map_selection_page.dart`:
   - `import 'package:baller_app/services/load_position.dart';`
   - `final LocationService locationService = LocationService();`
   - `loadPosition()` in `initState` via `locationService.loadPosition()`.
   - Full-screen `CircularProgressIndicator` until `userPosition != null`.
   - `GoogleMap` `initialCameraPosition` from `LatLng(userPosition!.latitude, userPosition!.longitude)` with zoom `16`.
   - `onMapCreated` → `_moveCameraToUser()` with null guards.
2. Run `cd baller_app && flutter analyze lib/pages/Map`.

**Result:** Page blocks until position is available; if permission denied forever, user stays on spinner unless you add error UI in `LocationService`/page.

## Common Issues

- **Console:** `❌ Location Service off` and map never centers
  1. Enable location on device/emulator (Android: Settings → Location; iOS: Settings → Privacy → Location).
  2. Retry after cold start; `loadPosition()` does not auto-retry.

- **Console:** `❌ Permission denied forever` and `userPosition` stays `null`
  1. Expected from `load_position.dart` — returns `null`.
  2. User must enable location in system Settings for Baller App.
  3. Optional: `await Geolocator.openAppSettings()` inside `LocationService` when `permission == LocationPermission.deniedForever`.

- **Crash:** `Null check operator used on a null value` on `userPosition!`
  1. Check `map_page.dart` `loadPosition()` — camera uses `userPosition!` without null guard when `mapController != null`.
  2. Wrap with `if (mapController != null && userPosition != null) { ... }` (pattern in `map_selection_page.dart` `_moveCameraToUser()`).
  3. Re-run `cd baller_app && flutter analyze lib/pages/Map`.

- **iOS:** Location prompt never appears / immediate denial
  1. Open `baller_app/ios/Runner/Info.plist` — remove duplicate `NSLocationWhenInUseUsageDescription` keys; keep one string.
  2. Delete app from simulator, `cd baller_app && flutter clean`, `flutter run`.
  3. Verify: `grep NSLocationWhenInUse baller_app/ios/Runner/Info.plist`.

- **Android:** `PERMISSION_DENIED` or no blue location dot
  1. Confirm `ACCESS_FINE_LOCATION` in `baller_app/android/app/src/main/AndroidManifest.xml` (remove duplicate `<uses-permission>` blocks at lines ~41 and ~54).
  2. Runtime request runs via `Geolocator.requestPermission()` in `loadPosition()` — ensure that method executed.
  3. Uninstall/reinstall if user chose "Don't ask again".

- **Analyzer:** `The name 'Position' isn't a type`
  1. Add `import 'package:geolocator/geolocator.dart';` to the page file.
  2. GPS position is geolocator's `Position`, not `google_maps_flutter` `LatLng`.

- **Courts load but distances never appear**
  1. `userPosition` is `null` — check `❌` debug prints from `LocationService`.
  2. Confirm `updateSortedCourts()` runs after `loadPosition()` sets `userPosition`.
  3. Confirm UI uses `if (userPosition != null)` before distance `Text` (~`map_page.dart` line 262).

- **Wrong package / version errors after adding GPS**
  1. Use existing `geolocator: ^14.0.2` in `baller_app/pubspec.yaml` only.
  2. `cd baller_app && flutter pub get && flutter analyze lib/services`.