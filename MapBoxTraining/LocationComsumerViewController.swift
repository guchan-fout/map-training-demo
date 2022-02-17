//
//  LocationComsumerViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/02/17.
//

import UIKit
import MapboxMaps

public class LocationComsumerViewController: UIViewController, CLLocationManagerDelegate {
    
    internal var mapView: MapView!
    internal var locationManager: CLLocationManager!
    internal var locationConsumer: CustomLocationConsumer!
    internal var setNewLocation: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Set initial camera settings
        let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 10.0, pitch: 0)
        let options = MapInitOptions(cameraOptions: cameraOptions)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()

        
        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            print("Maploaded")
            self.locationConsumer = CustomLocationConsumer(mapView: self.mapView)
        }
        
        setNewLocation = UIButton(frame: CGRect(x: 10,
                                      y: 150,
                                      width: 100,
                                      height: 30))
        
        setNewLocation.setTitleColor(.blue, for: .normal)
        setNewLocation.isHidden = false
        setNewLocation.setTitle("new Location", for: .normal)
        setNewLocation.addTarget(self, action: #selector(moveToNewLocation), for: .touchUpInside)
        view.addSubview(setNewLocation)
    }
    
    @objc func moveToNewLocation() {
        let coordinate = CLLocation(latitude: 35.62199867811333, longitude: 139.10981792443334)
        let location = Location(with: coordinate, heading:nil)
        //let location = Location(location: coordinate, heading: CLLocationManager.init().heading?.magneticHeading, accuracyAuthorization: 0)
        self.locationConsumer.locationUpdate(newLocation: location)
    }
}

public class CustomLocationConsumer: LocationConsumer {
    weak var mapView: MapView?
    
    init(mapView: MapView) {
        self.mapView = mapView
    }
    
    public func locationUpdate(newLocation: Location) {
        print("get new location:\(newLocation.location.debugDescription)")
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 10),
            duration: 5)
        
        var pointAnnotation = PointAnnotation(coordinate: newLocation.coordinate)

        // Make the annotation show a red pin
        pointAnnotation.image = .init(image: UIImage(named: "red_pin")!, name: "red_pin")
        pointAnnotation.iconAnchor = .bottom
        let pointAnnotationManager = self.mapView?.annotations.makePointAnnotationManager()
        pointAnnotationManager?.annotations = [pointAnnotation]
        
        
    }
}
