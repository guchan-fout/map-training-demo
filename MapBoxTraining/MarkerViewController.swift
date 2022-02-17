//
//  ViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/02/17.
//

import UIKit
import MapboxMaps

public class MarkerViewController: UIViewController {
    
    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial camera settings
        let options = MapInitOptions(cameraOptions: CameraOptions(zoom: 10.0))
        
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
        
        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()

        
        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            // Register the location consumer with the map
            // Note that the location manager holds weak references to consumers, which should be retained
            self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
            let coordinate = CLLocation(latitude: 35.62199867811333, longitude: 139.10981792443334)
            let location = Location(with: coordinate, heading:nil)
            //let location = Location(location: coordinate, heading: CLLocationManager.init().heading?.magneticHeading, accuracyAuthorization: 0)
            self.cameraLocationConsumer.locationUpdate(newLocation: location)
             // Needed for internal testing purposes.
        }
    }
}


