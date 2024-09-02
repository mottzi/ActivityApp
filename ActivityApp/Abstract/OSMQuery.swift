import SwiftUI
import MapKit

/// Build OSM OverPass API queries with category and coordinate region filters.
class OSMQuery
{
    /// Builds an Overpass API query that can be used to fetch OSM POI that are inside a coordinate region and match category filters.
    /// - Parameters:
    ///   - categoryFilters: An array of `[OSMPointOfInterestCategory]`. The elements act as category filters, meaning that the query will only return POI that match at least one of these categories.
    ///   - region: A `MKCoordinateRegion` type that prepresents the bounding box (bbox) of the OSM query.
    /// - Returns: The query as `String` or `nil` if an error has occured.
    static func buildQuery(using categoryFilters: [OSMPointOfInterestCategory], region: MKCoordinateRegion) -> String?
    {
        // abort if empty category
        guard !categoryFilters.isEmpty else { return nil }
        
        // convert MapKit-region to OSM-bbox
        let bbox = appleRegionToOSMBoundingBox(region: region)
        
        // get json that only contains elements inside bbox
        var query = "[out:json][bbox:\(bbox.0), \(bbox.1), \(bbox.2), \(bbox.3)];("
        
        for category in categoryFilters
        {
            // category is a tag-value-pair ["amenity"="cinema"]
            if let value = category.value
            {
                query += "nwr[\"name\"][\"\(category.name)\"=\"\(value)\"];"
            }
            // category is a standalone tag ["sport"]
            else
            {
                query += "nwr[\"name\"][\"\(category.name)\"];"
            }
        }
        
        // center is necessary so way-elements have a coordinate (like nodes)
        query += ");out center;"
        
        return query
    }
}

extension OSMQuery
{
    /// Converts MKCoordinateRegion (MapKit) to the OSM bounding box (bbox) coordinate format.
    /// - Parameter region: MKCoordinateRegion to be converted to bbox.
    /// - Returns: Tuple containing the raw values making up the bbox in following order: south-west-latitude, south-west-longitude, north-east-latitude, north-east-longitude.
    static func appleRegionToOSMBoundingBox(region: MKCoordinateRegion) -> (Double, Double, Double, Double)
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
        return (swLatitude, swLongitude, neLatitude, neLongitude)
    }
}
