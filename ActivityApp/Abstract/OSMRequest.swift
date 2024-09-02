import SwiftUI
import MapKit

/// A type that represents a OSM map item that has been fetched using a category filter.
struct OSMFilteredMapItem: Identifiable
{
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var category: MapCategory
}

/// Make requests to the OSM OverPass API to fetch POI using category and coordinate region filters.
class OSMRequest
{
    var category: MapCategory
    var region: MKCoordinateRegion
    
    init(for category: MapCategory, region: MKCoordinateRegion)
    {
        self.category = category
        self.region = region
    }
    
    /// Runs the request.
    /// - Returns: Array of ``OSMFilteredMapItem`` that contains the POIs that matched at least one of the category filters and the coordinate region filter. If an error occured or no POIs were found, `nil` is returned.
    func start() async -> [OSMFilteredMapItem]?
    {
        // make sure we have OSM categories
        guard let categories = self.category.osmCategories else { return nil }
        guard !categories.isEmpty else { return nil }
        
        // prepare query string
        guard let rawQuery = OSMQuery.buildQuery(using: categories, region: self.region),
              let query = rawQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let urlQuery = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)")
        else { return nil }
        
        // prepare GET API request
        var request = URLRequest(url: urlQuery)
        request.httpMethod = "GET"
        
        // perform async API request
        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        
        // try to access elements array
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let elements = json["elements"] as? [[String: Any]]
        else { return nil }
        
        var parsedElements: [OSMFilteredMapItem] = []
        
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
            
            guard let coordinate else { continue }
            
            let mapItem = OSMFilteredMapItem(name: name, coordinate: coordinate, category: self.category)
            
            parsedElements.append(mapItem)
        }
        
        // check if any elements were parsed
        guard !parsedElements.isEmpty else { return nil }
        
        // return parsed elements
        return parsedElements
    }
}
