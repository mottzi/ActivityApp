import SwiftUI
import MapKit

@Observable class MapManager
{    
    @ObservationIgnored weak var categoryManager: CategoryManager?
    
    @ObservationIgnored let locationManager = CLLocationManager()
    @ObservationIgnored var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservationIgnored var region: MKCoordinateRegion?
    
    var appleSearchResults: [MKFilteredMapItem] = []
    var osmSearchResults: [OSMFilteredMapItem] = []

    public func requestAuthorization()
    {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func resetToUserLocation()
    {
        withAnimation { position = .userLocation(fallback: .automatic) }
    }
    
    public func toggleMapMarkers(for category: MapCategory)
    {
        guard let region else { return }

        if category.isSelected
        {
            addMapMarkers(for: category, region: region, platform: .apple)
            addMapMarkers(for: category, region: region, platform: .osm)
        }
        else
        {
            removeMapMarkers(for: category)
        }
    }
}

extension MapManager
{
    enum MapPlatform
    {
        case apple
        case osm
    }
        
    private func addMapMarkers(for category: MapCategory, region: MKCoordinateRegion, platform: MapPlatform)
    {
        switch platform
        {
            case .apple: addMapMarkersApple(for: category, region: region)
            case .osm: addMapMarkersOSM(for: category, region: region)
        }
    }

    private func addMapMarkersOSM(for category: MapCategory, region: MKCoordinateRegion)
    {
        Task.detached
        {
            let request = OSMRequest(for: category, region: region)

            guard let foundItems = await request.start() else { return }
            
            DispatchQueue.main.async
            {
                self.osmSearchResults.append(contentsOf: foundItems)
            }
        }
    }
    
    private func addMapMarkersApple(for category: MapCategory, region: MKCoordinateRegion)
    {
        Task.detached
        {
            let request = AppleRequest(with: category, region: region)

            guard let foundItems = await request.start() else { return }
            
            DispatchQueue.main.async
            {
                self.appleSearchResults.append(contentsOf: foundItems)
            }
        }
    }
    
    private func removeMapMarkers(for category: MapCategory)
    {
        appleSearchResults = appleSearchResults.filter { $0.category.id != category.id }
        osmSearchResults = osmSearchResults.filter { $0.category.id != category.id }
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

extension CLLocationCoordinate2D
{
    static var pratteln: Self
    {
        return .init(latitude: 47.52255706015097, longitude: 7.691808136110408)
    }
}
