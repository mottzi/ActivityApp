import SwiftUI
import MapKit



@Observable class MapManager
{    
    weak var filterManager: FilterManager?
    
    @ObservationIgnored let locationManager = CLLocationManager()
    @ObservationIgnored var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservationIgnored var region: MKCoordinateRegion?
    
    var appleSearchResults: [MKMapTagItem] = []
    var osmSearchResults: [OSMMapTagItem] = []

    public func requestAuthorization()
    {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func resetToUserLocation()
    {
        withAnimation { position = .userLocation(fallback: .automatic) }
    }
    
    public func toggleMapMarkers(for tag: MapFilter)
    {
        guard let region else { return }

        if tag.isSelected
        {
            addMapMarkers(for: tag, region: region, platform: .apple)
            addMapMarkers(for: tag, region: region, platform: .osm)
        }
        else
        {
            removeMapMarkers(for: tag)
        }
    }
}

extension MapManager
{


    private func addMapMarkers(for tag: MapFilter, region: MKCoordinateRegion, platform: MapPlatform)
    {
        switch platform
        {
            case .apple: addMapMarkersApple(for: tag, region: region)
            case .osm: addMapMarkersOSM(for: tag, region: region)
        }
    }

    private func addMapMarkersOSM(for tag: MapFilter, region: MKCoordinateRegion)
    {
        let request = OSMRequest(for: tag, region: region)
        
        Task.detached
        {
            guard let foundItems = await request.start() else { return }
            
            DispatchQueue.main.async
            {
                self.osmSearchResults.append(contentsOf: foundItems)
            }
        }
    }
    
    enum MapPlatform
    {
        case apple
        case osm
    }

    struct MKMapTagItem: Identifiable
    {
        let id = UUID()
        let mapItem: MKMapItem
        let tag: MapFilter
    }
    
    private func addMapMarkersApple(for tag: MapFilter, region: MKCoordinateRegion)
    {
        guard let category = tag.apple else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = tag.title
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category)
        request.region = region
        
        Task.detached
        {
            guard let response = try? await MKLocalSearch(request: request).start() else { return }
            
            guard let tagManager = self.filterManager,
                  let index = tagManager.allTags.firstIndex(of: tag),
                  tagManager.allTags[index].isSelected == true
            else { return }
            
            let result = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
            
            let taggedResult = result.map { MKMapTagItem(mapItem: $0, tag: tag) }
            
            let newResults = self.appleSearchResults + taggedResult
            
            DispatchQueue.main.async
            {
                self.appleSearchResults = newResults
            }
        }
    }
    
    private func removeMapMarkers(for tag: MapFilter)
    {
        appleSearchResults = appleSearchResults.filter { return $0.tag.id != tag.id }
        osmSearchResults = osmSearchResults.filter { return $0.tag.id != tag.id }
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
