import SwiftUI
import MapKit

/// A type that defines a catoegory for filtering POIs on OSM or Apple Maps.
struct MapCategory: Identifiable, Hashable
{
    let id = UUID()
    let title: String
    var icon: String = "circle"
    var isSelected: Bool = false
    var osmCategories: [OSMPointOfInterestCategory]? = nil
    var appleCategories: [MKPointOfInterestCategory]? = nil
}

/// A type that represents a OSM tag with its optional value.
struct OSMPointOfInterestCategory: Hashable
{
    /// The name of a category is an OSM tag.
    var name: String
    /// The value of a category is the value of an OSM tag.
    var value: String?
    
    init(_ name: String, _ value: String? = nil)
    {
        self.name = name
        self.value = value
    }
}

extension MapCategory
{
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "movieclapper", osmCategories: [.init("amenity", "cinema")], appleCategories: [.movieTheater]),
        MapCategory(title: "Park", icon: "tree", osmCategories: [.init("leisure", "park")], appleCategories: [.park, .nationalPark]),
        MapCategory(title: "Eat", icon: "fork.knife", osmCategories: [.init("amenity", "restaurant"), .init("amenity", "fast_food"), .init("amenity", "cafe"), .init("shop", "bakery"), .init("shop", "pastry")], appleCategories: [.cafe, .restaurant, .bakery]),
        MapCategory(title: "Sport", icon: "volleyball", osmCategories: [.init("sport"), .init("leisure", "pitch")], appleCategories: [.fitnessCenter, .stadium]),
        MapCategory(title: "Museum", icon: "building.columns", osmCategories: [.init("tourism", "museum"), .init("museum")], appleCategories: [.museum]),
        MapCategory(title: "Zoo", icon: "bird", osmCategories: [.init("tourism", "zoo"), .init("zoo")], appleCategories: [.zoo]),
        MapCategory(title: "Amusement", icon: "laser.burst", osmCategories: [.init("attraction", "amusement_ride"), .init("leisure", "amusement_arcade"), .init("leisure", "water_park"), .init("tourism", "theme_park")], appleCategories: [.amusementPark]),
    ]
}
