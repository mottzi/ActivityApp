import SwiftUI
import MapKit
import CoreLocation

@Observable class UserLocation: NSObject, CLLocationManagerDelegate
{
    @ObservationIgnored private let locationManager = CLLocationManager()
    @ObservationIgnored private let geocoder = CLGeocoder()
    
    @ObservationIgnored private(set) var location: CLLocation?
    @ObservationIgnored private(set) var region: MKCoordinateRegion?
    private(set) var regionFound: Bool = false
    
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        switch manager.authorizationStatus
        {
            case .notDetermined: manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse: manager.requestLocation()
                
            default: self.location = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let newLocation = locations.last
        {
            self.location = newLocation
            
            findTownName(for: newLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error: \(error.localizedDescription)")
    }
    
    private func findTownName(for location: CLLocation)
    {
        geocoder.reverseGeocodeLocation(location)
        { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error
            {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first,
               let town = placemark.locality ?? placemark.subAdministrativeArea
            {
                self.findTownRegion(for: town)
            }
        }
    }
    
    private func findTownRegion(for town: String)
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = town
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error
            {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            if let boundingRegion = response?.boundingRegion
            {
                self.region = boundingRegion
                self.regionFound = true
            }
        }
    }
}
