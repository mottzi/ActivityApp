import SwiftUI
import MapKit

struct OSMTag: Identifiable, Hashable
{
    let id = UUID()
    
    let name: String
    var category: [MKPointOfInterestCategory]? = nil
    var icon: String = "circle"
    var isSelected: Bool = false
}

extension OSMTag
{
    static let allTags: [OSMTag] =
    [
        OSMTag(name: "Movies", category: .init(arrayLiteral: .movieTheater), icon: "movieclapper"),
        OSMTag(name: "Park", category: .init(arrayLiteral: .park, .nationalPark), icon: "tree"),
        OSMTag(name: "Eat", category: .init(arrayLiteral: .cafe, .restaurant, .bakery) , icon: "fork.knife"),
        OSMTag(name: "Sport", category: .init(arrayLiteral: .fitnessCenter, .stadium), icon: "volleyball"),
        OSMTag(name: "Museum", category: .init(arrayLiteral: .museum), icon: "building.columns"),
        OSMTag(name: "Zoo", category: .init(arrayLiteral: .zoo), icon: "bird"),
        OSMTag(name: "Amusement", category: .init(arrayLiteral: .amusementPark), icon: "laser.burst"),
    ]
}
