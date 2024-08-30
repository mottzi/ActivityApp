import SwiftUI
import MapKit

@Observable class MapManager
{    
    @ObservationIgnored var appManager: AppManager? = nil
    @ObservationIgnored let locationManager = CLLocationManager()
    @ObservationIgnored var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservationIgnored var region: MKCoordinateRegion?
    
    var searchResults: [MKMapTagItem] = []
    
    func requestAuthorization()
    {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func resetToUserLocation()
    {
        withAnimation { self.position = .userLocation(fallback: .automatic) }
    }
}

extension MKCoordinateRegion 
{
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool 
    {
        let latDelta = self.span.latitudeDelta / 2.0
        let lonDelta = self.span.longitudeDelta / 2.0
        
        let minLat = self.center.latitude - latDelta
        let maxLat = self.center.latitude + latDelta
        let minLon = self.center.longitude - lonDelta
        let maxLon = self.center.longitude + lonDelta
        
        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
}
