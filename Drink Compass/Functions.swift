import CoreLocation

func computeBearing(from userLocation: CLLocationCoordinate2D, to targetLocation: CLLocationCoordinate2D) -> Double {
    let lat1 = userLocation.latitude.degreesToRadians
    let lon1 = userLocation.longitude.degreesToRadians
    let lat2 = targetLocation.latitude.degreesToRadians
    let lon2 = targetLocation.longitude.degreesToRadians
    
    let dLon = lon2 - lon1
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radians = atan2(y, x)
    
    return radians.radiansToDegrees
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
