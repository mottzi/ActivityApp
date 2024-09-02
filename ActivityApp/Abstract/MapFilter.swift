import SwiftUI
import MapKit

struct MapFilter: Identifiable, Hashable
{
    let id = UUID()
    let title: String
    var icon: String = "circle"
    var isSelected: Bool = false
    var osm: [OSMPair]? = nil
    var apple: [MKPointOfInterestCategory]? = nil
}

extension MapFilter
{
    static let allFilters: [MapFilter] =
    [
        MapFilter(title: "Movies", icon: "movieclapper", osm: [.init("amenity", "cinema")], apple: [.movieTheater]),
        MapFilter(title: "Park", icon: "tree", osm: [.init("leisure", "park")], apple: [.park, .nationalPark]),
        MapFilter(title: "Eat", icon: "fork.knife", osm: [.init("amenity", "restaurant"), .init("amenity", "fast_food"), .init("amenity", "cafe"), .init("shop", "bakery"), .init("shop", "pastry")], apple: [.cafe, .restaurant, .bakery]),
        MapFilter(title: "Sport", icon: "volleyball", osm: [.init("sport"), .init("leisure", "pitch")], apple: [.fitnessCenter, .stadium]),
        MapFilter(title: "Museum", icon: "building.columns", osm: [.init("tourism", "museum"), .init("museum")], apple: [.museum]),
        MapFilter(title: "Zoo", icon: "bird", osm: [.init("tourism", "zoo"), .init("zoo")], apple: [.zoo]),
        MapFilter(title: "Amusement", icon: "laser.burst", osm: [.init("attraction", "amusement_ride"), .init("leisure", "amusement_arcade"), .init("leisure", "water_park"), .init("tourism", "theme_park")], apple: [.amusementPark]),
    ]
}

struct OSMPair: Hashable
{
    var name: String
    var value: String?
    
    init(_ name: String, _ value: String? = nil)
    {
        self.name = name
        self.value = value
    }
}
