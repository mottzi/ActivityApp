import SwiftUI
import MapKit

@Observable class MapManager
{    
    weak var tagManager: TagManager?
    
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
    
    public func toggleMapMarkers(for tag: OSMTag)
    {
        guard let region else { return }

        if tag.isSelected
        {
            addMapMarkers(for: tag, region: region)
            addMapMarkersOSM(for: tag, region: region)
        }
        else
        {
            removeMapMarkers(for: tag)
        }
    }
    
    private func addMapMarkersOSM(for tag: OSMTag, region: MKCoordinateRegion)
    {
        // prepare query string
        guard let rawQuery = OSM.buildQuery(for: tag, region: region),
              let query = rawQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let urlQuery = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)")
        else { return }

        // prepare GET http request
        var request = URLRequest(url: urlQuery)
        request.httpMethod = "GET"
        
        var mapItems: [OSMMapTagItem] = []
        
        // start request
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            if error != nil { return }
            guard let data else { return }
            
            // try to access elements array
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let elements = json["elements"] as? [[String: Any]]
            else { return }
            
            // loop over all elements
            for element in elements
            {
                // try to access name tag
                guard let tags = element["tags"] as? [String: String],
                      let name = tags["name"]
                else { continue }
                
                var coordinate: CLLocationCoordinate2D?
                
                // save coordinate for node type
                if let lat = element["lat"] as? Double, let lon = element["lon"] as? Double
                {
                    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
                // save center-coordinate for way type
                else if let center = element["center"] as? [String: Double],
                        let lat = center["lat"], let lon = center["lon"]
                {
                    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
                
                guard let coordinate else { return }
                
                let mapItem = OSMMapTagItem(name: name, coordinate: coordinate, tag: tag)
                mapItems.append(mapItem)
            }
            
            DispatchQueue.main.async
            {
                self.osmSearchResults.append(contentsOf: mapItems)
            }
        }
                
        task.resume()
    }
    
    private func addMapMarkers(for tag: OSMTag, region: MKCoordinateRegion)
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
            
            guard let tagManager = self.tagManager,
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
    
    private func removeMapMarkers(for tag: OSMTag)
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


struct MKMapTagItem: Hashable
{
    let mapItem: MKMapItem
    let tag: OSMTag
}
