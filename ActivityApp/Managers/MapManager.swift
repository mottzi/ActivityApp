import SwiftUI
import MapKit

@Observable class MapManager
{    
    weak var tagManager: TagManager?
    
    @ObservationIgnored let locationManager = CLLocationManager()
    @ObservationIgnored var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservationIgnored var region: MKCoordinateRegion?
    
    var searchResults: [MKMapTagItem] = []
    
    public func requestAuthorization()
    {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func resetToUserLocation()
    {
        withAnimation { position = .userLocation(fallback: .automatic) }
    }
    
    public func toggleMapMarkers(for tag: OSMTag)
    {
        guard let region,
              let category = tag.apple
        else { return }

        if tag.isSelected
        {
            // addMapMarkers(for: tag, category: category, region: region)
            
            addMapMarkersOSM(for: tag, region: region)
        }
        else
        {
            removeMapMarkers(for: tag)
        }
    }
    
    private func addMapMarkersOSM(for tag: OSMTag, region: MKCoordinateRegion)
    {
        print("Fetching items for '\(tag.title)'")
        
        guard let rawQuery = OSMManager.buildQuery(for: tag, region: region),
              let query = rawQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return print("error: encode") }
        
        print("Query:")
        print(rawQuery)
                
        guard let urlQuery = URL(string: "http://overpass-api.de/api/interpreter?data=\(query)")
        else { return print("error: url") }

        print("URL-Query:")
        print(urlQuery)
    }
    
    private func addMapMarkers(for tag: OSMTag, category: [MKPointOfInterestCategory], region: MKCoordinateRegion)
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = tag.title
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category)
        request.region = region
        
        Task.detached 
        {
            guard let response = try? await MKLocalSearch(request: request).start() else { return }
            
            guard let tagManager = self.tagManager,
                  let index = tagManager.allTags.firstIndex(of: tag),
                  tagManager.allTags[index].isSelected == true
            else { return }
            
            let result = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
            let taggedResult = result.map { MKMapTagItem(mapItem: $0, tag: tag) }
            let newResults = self.searchResults + taggedResult
            
            DispatchQueue.main.async { withAnimation { self.searchResults = newResults } }
        }
    }
    
    private func removeMapMarkers(for tag: OSMTag)
    {
        searchResults = searchResults.filter { return $0.tag.id != tag.id }
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

struct MKMapTagItem: Hashable
{
    let mapItem: MKMapItem
    let tag: OSMTag
}
