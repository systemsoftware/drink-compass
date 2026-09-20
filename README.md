# Drink Compass

Drink Compass is a SwiftUI app that points toward the nearby place with the shortest estimated driving time. Choose a category, let the app search around your current location, and follow the animated compass needle to the selected destination.

## Features

- Searches for nearby liquor stores, pharmacies, grocery stores, gas stations, restaurants, and cafes.
- Combines several MapKit search terms for each category and removes duplicate results.
- Compares driving ETAs for the eight closest candidates and selects the quickest destination.
- Refreshes the search after the device moves at least 250 meters.
- Displays all nearby results on a map and lets you choose a different destination.
- Opens the selected business in Apple Maps.
- Uses a spring-animated compass needle and respects Reduce Motion.
- Includes a layered Icon Composer app icon.

## Requirements

- Xcode 26 or newer
- iOS 26, macOS 26, or visionOS 26
- A device or simulator with location services available

The project uses SwiftUI, MapKit, and Core Location and has no third-party dependencies.

## Running the app

1. Open `Drink Compass.xcodeproj` in Xcode.
2. Select the **Drink Compass** scheme and a supported destination.
3. If necessary, choose your own development team under **Signing & Capabilities**.
4. Build and run the app.
5. Allow location access while using the app.

Heading updates work best on a physical device. If you use a simulator, provide a simulated location and be aware that compass-heading behavior may be limited.

## Usage

Use the category picker in the toolbar to choose what you want to find. While MapKit checks nearby candidates, the app shows the place currently being evaluated. Once the search finishes, the compass points toward the destination with the shortest driving ETA.

Tap the map button to see the other nearby results. Selecting a map marker changes the compass destination. From the map screen, use the external-link button to open the selected place in Apple Maps.

Double-tap the compass needle to clear the current destination and run the search again.

## Location and privacy

Drink Compass requests **When In Use** location access to find nearby places and calculate the direction from the device to the selected destination. Location and heading updates are handled on-device through Core Location; nearby-place searches, ETA calculations, and business details are provided by MapKit. The app does not include analytics or third-party tracking dependencies.

If location permission is denied or location services are unavailable, the app cannot select a nearby destination.

## Legal

- [Privacy Policy](PRIVACY_POLICY.md)
- [Terms of Use](TERMS_OF_USE.md)

## Third-party assets

The app icon incorporates Google's **storefront** and **near_me** icons from [Material Symbols](https://fonts.google.com/icons). Material Symbols are provided by Google under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). The symbols are used as layers in Drink Compass's custom app-icon composition.

## Project structure

- `ContentView.swift` — search orchestration, ETA comparison, and compass UI
- `LocationManager.swift` — Core Location authorization, position, and heading updates
- `MapList.swift` — map markers and manual destination selection
- `Types.swift` — supported place categories and their MapKit search terms
- `Functions.swift` — bearing calculation helpers
- `app.icon` — layered Icon Composer source and image assets
