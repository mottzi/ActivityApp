import SwiftUI
import MapKit

class OSMManager
{
    static func buildQuery(for tag: OSMTag, region: MKCoordinateRegion) -> String?
    {
        guard let pairs = tag.osm else { return nil }
        guard !pairs.isEmpty else { return nil }
        
        let bbox = regionToBoundingBox(region: region)
        
        var query = "[out:json][bbox:\(bbox.0), \(bbox.1), \(bbox.2), \(bbox.3)];("
        
        for pair in pairs
        {
            if let value = pair.value
            {
                query += "node[\"name\"][\"\(pair.name)\"=\"\(value)\"];"
            }
            else
            {
                query += "node[\"name\"][\"\(pair.name)\"];"
            }
        }
        
        query += ");out body;"
        
        return query
    }
    
    static func regionToBoundingBox(region: MKCoordinateRegion) -> (Double, Double, Double, Double)
    {
        // Calculate the span of the region
        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta
        
        // Calculate SW (Southwest) corner
        let swLatitude = region.center.latitude - (latitudeDelta / 2.0)
        let swLongitude = region.center.longitude - (longitudeDelta / 2.0)
        
        // Calculate NE (Northeast) corner
        let neLatitude = region.center.latitude + (latitudeDelta / 2.0)
        let neLongitude = region.center.longitude + (longitudeDelta / 2.0)
        
        // Return the coordinates in the (SW, SW, NE, NE) format
        return (swLatitude: swLatitude, swLongitude: swLongitude, neLatitude: neLatitude, neLongitude: neLongitude)
    }
}
