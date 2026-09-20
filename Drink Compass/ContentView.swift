import SwiftUI
import MapKit
 

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var targetLocation: CLLocationCoordinate2D?
    @State private var targetName = "NOTHING"
    
    @State var others: [MKMapItem] = []
    
    @State private var finding = ""
    
    @AppStorage("type") var findType: FindType = .liquorStore
    
    @State var locked = false
    @State private var lastSearchLocation: CLLocation?
    
    @State private var selectedPlace: MKMapItem?

    private var locationUpdateID: LocationUpdateID? {
        guard let location = locationManager.location else { return nil }

        return LocationUpdateID(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let userLocation = locationManager.location, targetName != "NOTHING" {
                    
                    let bearing = computeBearing(
                        from: userLocation,
                        to: targetLocation ?? CLLocationCoordinate2D()
                    )
                    
                    CompassNeedle(
                        direction: bearing - locationManager.heading
                    )
                    .onTapGesture(count: 2) {
                        locked = false
                        targetName = "NOTHING"
                        lastSearchLocation = nil
                    }
                    
                    Text("Pointing to \(targetName)")
                        .padding()
                } else {
                    ProgressView(finding.isEmpty ? "Finding..." : "Found \(finding)...")
                }
            }
            .toolbar {
            Picker(selection: $findType) {
                    ForEach(FindType.allCases) { type in
                        Text(type.displayName)
                            .tag(type)
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                
                NavigationLink {
                    MapList(others: others, targetLocation: $targetLocation, targetName: $targetName)
                } label: {
                    Image(systemName: "map")
                }
            }
            .onChange(of: findType) {
                locked = false
                lastSearchLocation = nil
                targetName = "NOTHING"
            }
            .task(id: locationUpdateID) {
                
                if locked {
                    return
                }
                
                guard let location = locationManager.location else {
                    return
                }

                let currentLocation = CLLocation(
                    latitude: location.latitude,
                    longitude: location.longitude
                )

                if let lastSearchLocation,
                   currentLocation.distance(from: lastSearchLocation) < 250 {
                    return
                }
                
                locked = true
                lastSearchLocation = currentLocation
                
                Task {
                    await findNearest(near: location)
                    locked = false
                }
            }
        }
    }
    
    @MainActor
    func findNearest(
        near userCoordinate: CLLocationCoordinate2D
    ) async {
        let userLocation = CLLocation(
            latitude: userCoordinate.latitude,
            longitude: userCoordinate.longitude
        )

        let region = MKCoordinateRegion(
            center: userCoordinate,
            latitudinalMeters: 5_000,
            longitudinalMeters: 5_000
        )

        let queries = findType.searchTerms

        var allResults: [MKMapItem] = []

        for query in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            request.resultTypes = .pointOfInterest

            do {
                let response = try await MKLocalSearch(
                    request: request
                ).start()

                allResults.append(contentsOf: response.mapItems)

            } catch {
                print("Search failed for \(query):", error)
            }
        }

        var seen = Set<String>()

        let uniqueResults = allResults.filter { item in
            let coordinate = item.location.coordinate

            let key = """
            \(item.name ?? "")
            \(coordinate.latitude.rounded(toPlaces: 4))
            \(coordinate.longitude.rounded(toPlaces: 4))
            """

            return seen.insert(key).inserted
        }

        let nearbyResults = uniqueResults
            .filter { item in
                distance(
                    from: userLocation,
                    to: item
                ) < 8_000
            }
            .sorted { a, b in
                distance(from: userLocation, to: a) <
                distance(from: userLocation, to: b)
            }

        print("LOCAL CANDIDATES:")

        for item in nearbyResults {
            print(
                item.name ?? "Unknown",
                Int(distance(from: userLocation, to: item)),
                "meters"
            )
        }

        let candidates = nearbyResults.prefix(8)

        let source = MKMapItem(
            location: userLocation,
            address: nil
        )

        var bestItem: MKMapItem?
        var bestTravelTime =
            TimeInterval.greatestFiniteMagnitude

        for item in candidates {
            let request = MKDirections.Request()
            request.source = source
            request.destination = item
            request.transportType = .automobile

            do {
                let eta = try await MKDirections(
                    request: request
                ).calculateETA()

                print(
                    item.name ?? "Unknown",
                    "\(Int(eta.expectedTravelTime / 60)) min"
                )
                
                finding = "\(item.name ?? "Unknown") (\(Int(eta.expectedTravelTime / 60)) min)"

                if eta.expectedTravelTime < bestTravelTime {
                    bestTravelTime = eta.expectedTravelTime
                    bestItem = item
                }

            } catch {
                print(
                    "Couldn't get ETA:",
                    item.name ?? "Unknown"
                )
            }
        }

        if let bestItem {
            targetLocation =
                bestItem.location.coordinate

            targetName =
                bestItem.name ?? "NOTHING"
            
            others = nearbyResults

            print(
                "SELECTED:",
                targetName,
                "\(Int(bestTravelTime / 60)) min"
            )
        }
    }

    func distance(from: CLLocation, to item: MKMapItem) -> CLLocationDistance {
        
        from.distance(from: item.location)

    }

    
}

private struct LocationUpdateID: Hashable {
    let latitude: Double
    let longitude: Double
}

private struct CompassNeedle: View {
    let direction: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedDirection = 0.0
    @State private var hasInitialDirection = false

    var body: some View {
        Image(systemName: "location.north.fill")
            .font(.system(size: 60))
            .rotationEffect(.degrees(displayedDirection))
            .onAppear {
                displayedDirection = direction
                hasInitialDirection = true
            }
            .onChange(of: direction) { _, newDirection in
                updateDirection(to: newDirection)
            }
    }

    private func updateDirection(to newDirection: Double) {
        guard hasInitialDirection else {
            displayedDirection = newDirection
            hasInitialDirection = true
            return
        }

        let change = shortestAngle(from: displayedDirection, to: newDirection)
        let target = displayedDirection + change

        if reduceMotion {
            displayedDirection = target
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                displayedDirection = target
            }
        }
    }

    private func shortestAngle(from current: Double, to target: Double) -> Double {
        var difference = (target - current).truncatingRemainder(dividingBy: 360)

        if difference > 180 {
            difference -= 360
        } else if difference < -180 {
            difference += 360
        }

        return difference
    }
}


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


func openBusinessProfile(_ name: String) {
    let businessCoordinate = CLLocationCoordinate2D(latitude: 40.7484, longitude: -74.0445)
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = name
    
    request.region = MKCoordinateRegion(
        center: businessCoordinate,
        latitudinalMeters: 200,
        longitudinalMeters: 200
    )
    
    let search = MKLocalSearch(request: request)
    search.start { response, error in
        guard let response = response, let officialBusinessItem = response.mapItems.first else {
            print("Business profile not found: \(String(describing: error))")
            return
        }
        
    officialBusinessItem.openInMaps(launchOptions: nil)
    }
}
