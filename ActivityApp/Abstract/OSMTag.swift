import SwiftUI
import MapKit

struct OSMTag: Identifiable, Hashable
{
    let id = UUID()
    let title: String
    var icon: String = "circle"
    var isSelected: Bool = false
    var osm: [OSMPairs]? = nil
    var apple: [MKPointOfInterestCategory]? = nil
}

extension OSMTag
{
    static let allTags: [OSMTag] =
    [
        OSMTag(title: "Movies", icon: "movieclapper", osm: [.init("amenity", "cinema")], apple: [.movieTheater]),
        OSMTag(title: "Park", icon: "tree", osm: [.init("leisure", "park")], apple: [.park, .nationalPark]),
        OSMTag(title: "Eat", icon: "fork.knife", osm: [.init("amenity", "restaurant"), .init("amenity", "fast_food"), .init("amenity", "cafe"), .init("shop", "bakery"), .init("shop", "pastry")], apple: [.cafe, .restaurant, .bakery]),
        OSMTag(title: "Sport", icon: "volleyball", osm: [.init("sport"), .init("leisure", "pitch")], apple: [.fitnessCenter, .stadium]),
        OSMTag(title: "Museum", icon: "building.columns", osm: [.init("tourism", "museum"), .init("museum")], apple: [.museum]),
        OSMTag(title: "Zoo", icon: "bird", osm: [.init("tourism", "zoo"), .init("zoo")], apple: [.zoo]),
        OSMTag(title: "Amusement", icon: "laser.burst", osm: [.init("attraction", "amusement_ride"), .init("leisure", "amusement_arcade"), .init("leisure", "water_park"), .init("tourism", "theme_park")], apple: [.amusementPark]),
    ]
}

struct OSMPairs: Hashable
{
    var name: String
    var value: String?
    
    init(_ name: String, _ value: String? = nil)
    {
        self.name = name
        self.value = value
    }
}
