import SwiftUI
import MapKit

@Observable class MapManager
{    
    let tagManager: TagManager
    
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    var camera: MapCamera?
    
    let locationManager = CLLocationManager()
    
    init(tagManager: TagManager)
    {
        self.tagManager = tagManager
    }
    
    func updateCamera(_ camera: MapCamera)
    {
        self.camera = camera
    }
    
    func requestAuthorization()
    {
        self.locationManager.requestWhenInUseAuthorization()
    }
}
