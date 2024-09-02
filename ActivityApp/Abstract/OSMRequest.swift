import SwiftUI
import MapKit

struct OSMMapTagItem: Identifiable
{
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var tag: MapFilter
}

class OSMRequest
{
    var tag: MapFilter
    var region: MKCoordinateRegion
    
    init(for tag: MapFilter, region: MKCoordinateRegion)
    {
        self.tag = tag
        self.region = region
    }
    
    func start() async -> [OSMMapTagItem]?
    {
        // prepare query string
        guard let rawQuery = OSMQuery.buildQuery(for: self.tag, region: self.region),
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
        
        var parsedElements: [OSMMapTagItem] = []
        
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
            
            let mapItem = OSMMapTagItem(name: name, coordinate: coordinate, tag: self.tag)
            
            parsedElements.append(mapItem)
        }
        
        // check if any elements were parsed
        guard !parsedElements.isEmpty else { return nil }
        
        // return parsed elements
        return parsedElements
    }
}
