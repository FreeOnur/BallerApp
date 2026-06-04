---
name: geolocation-courts
description: Wraps GPS access via `baller_app/lib/services/load_position.dart` (`LocationService.loadPosition`, geolocator permission flow) and platform keys in `Info.plist` / `AndroidManifest.xml`, then wires position into map pages for nearby court sorting. Use when the user says 'get location', 'nearby courts', 'sort by distance', 'map permissions', 'user position', or edits `load_position.dart`, `map_page.dart`, or `map_selection_page.dart`. Key capabilities: service-enabled checks, denied/deniedForever handling, `Geolocator.distanceBetween` sorting, and iOS/Android permission strings. Do NOT use for Supabase SQL, edge functions, `court_services.dart` queries, or new `Court` model fields (use `supabase-service` / `court-model` skills).
---
# Geolocation Courts

## Critical

- **Never call `Geolocator` directly from UI pages** for permission or `getCurrentPosition`. All GPS access goes through `LocationService` in `baller_app/lib/services/load_position.dart`.
- `loadPosition()` returns `Future<Position?>` — `null` means location services off, permission denied/deniedForever, or user declined. UI must handle `null` without force-unwrapping (`userPosition!`) except after an explicit null check.
- Nearby courts on the map use **client-side** distance via `Geolocator.distanceBetween` in `baller_app/lib/pages/Map/map_page.dart`; court rows still come from Supabase (`fetchCourts`). Do not add PostGIS/radius SQL for this skill.
- Before testing on device/simulator, confirm platform keys exist:
  - iOS: `baller_app/ios/Runner/Info.plist` — `NSLocationWhenInUseUsageDescription` (required for foreground GPS)
  - Android: `baller_app/android/app/src/main/AndroidManifest.xml` — `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`
- Dependency is already in `baller_app/pubspec.yaml`: `geolocator: ^14.0.2`. Do not add a second location package.
- Run validation from `baller_app/`: `flutter analyze lib/services/load_position.dart lib/pages/Map`

## Instructions

1. **Confirm platform permissions before changing Dart**
   - iOS (`baller_app/ios/Runner/Info.plist`): ensure `NSLocationWhenInUseUsageDescription` exists with a user-facing string (project uses German/English copy for nearby courts). Add `NSLocationAlwaysAndWhenInUseUsageDescription` only if background location is required.
   - Android (`baller_app/android/app/src/main/AndroidManifest.xml`): ensure these appear **once** under `<manifest>` (dedupe if duplicated):
     ```xml
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
     ```
   - Add `ACCESS_BACKGROUND_LOCATION` only for true background tracking; current map flow is foreground-only.
   - **Verify:** `grep -E "NSLocationWhenInUse|ACCESS_FINE" baller_app/ios/Runner/Info.plist baller_app/android/app/src/main/AndroidManifest.xml` shows the keys before proceeding.
   - This step uses no prior output.

2. **Use or extend `LocationService` — do not duplicate permission logic**
   - File: `baller_app/lib/services/load_position.dart`
   - Keep imports:
     ```dart
     import 'package:geolocator/geolocator.dart';
     import 'package:flutter/foundation.dart';
     ```
   - Preserve the existing flow (match line-for-line unless adding UI callbacks):
     1. `Geolocator.isLocationServiceEnabled()` → if false: `debugPrint("❌ Location Service off"); return null;`
     2. `Geolocator.checkPermission()` → if `LocationPermission.denied`: `requestPermission()`
     3. if `LocationPermission.deniedForever`: `debugPrint("❌ Permission denied forever"); return null;`
     4. `Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)`
   - If you need settings redirect for `deniedForever`, add it **inside** `LocationService` (e.g. `Geolocator.openAppSettings()`), not in widgets.
   - **Verify:** `flutter analyze lib/services/load_position.dart` passes before proceeding.
   - This step uses platform keys from Step 1.

3. **Wire location into a map page using existing field patterns**
   - Import: `import 'package:baller_app/services/load_position.dart';`
   - For distance math on courts, also: `import 'package:geolocator/geolocator.dart';`
   - State fields (from `map_page.dart` / `map_selection_page.dart`):
     ```dart
     final LocationService locationService = LocationService();
     Position? userPosition;
     ```
   - In `initState()`, call a page-local async method (do not block `initState` with `await`):
     ```dart
     @override
     void initState() {
       super.initState();
       loadPosition();
     }
     ```
   - Load method — prefer the **instance** field (see `map_selection_page.dart`):
     ```dart
     Future<void> loadPosition() async {
       userPosition = await locationService.loadPosition();
       setState(() {});
     }
     ```
   - Do **not** instantiate a second `LocationService()` in the same method if `locationService` already exists (`map_page.dart` currently calls `LocationService().loadPosition()` — new code should use `locationService.loadPosition()`).
   - **Verify:** no `userPosition!` without a preceding `if (userPosition != null)` guard before proceeding.
   - This step uses `LocationService` from Step 2.

4. **Handle `null` position in UI (required patterns)**
   - **Blocking UI** (pick location flow — `map_selection_page.dart`): while `userPosition == null`, show loading:
     ```dart
     if (userPosition == null) {
       return const Scaffold(
         body: Center(child: CircularProgressIndicator()),
       );
     }
     ```
   - **Non-blocking UI** (court list + map — `map_page.dart`): keep rendering courts; gate distance labels:
     ```dart
     if (userPosition != null)
       Text("${(distanceToCourt(court) / 1000).toStringAsFixed(1)} km entfernt", ...);
     ```
   - Camera animation: only when **both** `mapController != null` and `userPosition != null`:
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
   - **Verify:** app does not crash when permission is denied (lists still load, no `!` on null position) before proceeding.
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
   - Call `updateSortedCourts()` after `loadPosition()` completes and after search/filter changes.
   - Google Map: keep `myLocationEnabled: true` only when fine location is granted (current map already sets this).
   - **Verify:** with location granted, list shows `"X.X km entfernt"`; with location denied, courts still appear unsorted by distance.
   - This step uses `userPosition` from Step 3 and `Court` list from existing `fetchCourts()` (Supabase — do not modify query here).

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
1. Confirm `NSLocationWhenInUseUsageDescription` in `baller_app/ios/Runner/Info.plist` and `ACCESS_FINE_LOCATION` in `baller_app/android/app/src/main/AndroidManifest.xml`.
2. Leave `LocationService.loadPosition()` in `baller_app/lib/services/load_position.dart` unchanged.
3. In `baller_app/lib/pages/Map/map_page.dart`:
   - Import `package:baller_app/services/load_position.dart` and `package:geolocator/geolocator.dart`.
   - Add `Position? userPosition` and `final LocationService locationService = LocationService();`.
   - In `initState()`, call `loadPosition()` alongside existing `fetchCourts()`.
   - Implement `loadPosition()` → `userPosition = await locationService.loadPosition();` → `updateSortedCourts();` → guarded camera + `setState()`.
   - Keep `distanceToCourt` / `updateSortedCourts` as in existing `map_page.dart`.
4. Run `flutter analyze lib/pages/Map` from `baller_app/`.

**Result:** Approved courts load from Supabase; when GPS succeeds, list order and `"km entfernt"` labels reflect distance. When GPS fails, courts still display without crashing.

### Example 2: New screen that centers the map on the user

**User says:** "Add a page to pick a court location starting at my GPS position."

**Actions taken:**
1. Mirror `baller_app/lib/pages/Map/map_selection_page.dart`:
   - `import 'package:baller_app/services/load_position.dart';`
   - `final LocationService locationService = LocationService();`
   - `loadPosition()` in `initState` via `locationService.loadPosition()`.
   - Full-screen `CircularProgressIndicator` until `userPosition != null`.
   - `GoogleMap` `initialCameraPosition` from `LatLng(userPosition!.latitude, userPosition!.longitude)`.
2. Run `flutter analyze lib/pages/Map`.

**Result:** Page blocks until position is available or fails loading state if permission denied (extend with error UI if product requires it).

## Common Issues

- **Console:** `❌ Location Service off` and map never centers
  1. Enable location services on the device/emulator (Android: Settings → Location; iOS: Settings → Privacy → Location).
  2. Retry after cold start; `loadPosition()` does not retry automatically.

- **Console:** `❌ Permission denied forever` and `userPosition` stays `null`
  1. Expected behavior from `load_position.dart` — method returns `null`.
  2. User must enable location in system Settings for Baller App.
  3. Optional product fix: call `await Geolocator.openAppSettings()` inside `LocationService` when `permission == LocationPermission.deniedForever`.
  4. Re-run on device; do not call `getCurrentPosition` without passing Step 2 checks.

- **Crash:** `Null check operator used on a null value` on `userPosition!`
  1. Find unsafe use in `baller_app/lib/pages/Map/map_page.dart` `loadPosition()` (camera animation without null guard).
  2. Wrap with `if (mapController != null && userPosition != null) { ... }`.
  3. Re-run `flutter analyze lib/pages/Map`.

- **iOS:** Location prompt never appears / immediate denial
  1. Open `baller_app/ios/Runner/Info.plist` and ensure **one** `NSLocationWhenInUseUsageDescription` key (file currently has duplicate keys — remove duplicates, keep one string).
  2. Delete app from simulator, `flutter clean`, rebuild: `flutter run`.
  3. Verify key: `grep NSLocationWhenInUse baller_app/ios/Runner/Info.plist`.

- **Android:** `PERMISSION_DENIED` or no location dot on map
  1. Confirm `ACCESS_FINE_LOCATION` in `baller_app/android/app/src/main/AndroidManifest.xml` (remove duplicate `<uses-permission>` entries if present).
  2. On API 23+, permission is requested at runtime by `Geolocator.requestPermission()` in `loadPosition()` — ensure that method ran.
  3. Uninstall/reinstall app if user previously tapped "Don't ask again".

- **Analyzer:** `The name 'Position' isn't a type`
  1. Add `import 'package:geolocator/geolocator.dart';` to the page file.
  2. Do not confuse with `dart:ui` or map `LatLng` — GPS position is `geolocator`'s `Position`.

- **Courts load but distances never appear**
  1. `userPosition` is `null` — check debug prints from `LocationService`.
  2. Confirm `updateSortedCourts()` runs after `loadPosition()` sets state.
  3. Confirm UI uses `if (userPosition != null)` before `distanceToCourt` label (pattern in `map_page.dart` line ~262).

- **Wrong package / version errors after adding GPS**
  1. Use existing `geolocator: ^14.0.2` in `baller_app/pubspec.yaml` only.
  2. From `baller_app/`: `flutter pub get` then `flutter analyze lib/services`.