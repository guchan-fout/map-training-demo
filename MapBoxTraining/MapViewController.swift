//
//  MapViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2021/11/25.
//

import UIKit
import MapboxMaps

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    internal var mapView: MapView!
    internal var locationManager: CLLocationManager!
    internal var startCompassBtn: UIButton!
    internal var stopCompassBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView(frame: view.bounds)
        mapView.location.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self

    }
    
    func initMap() {
        print("initMap")
        print(CLLocationManager.init().location?.coordinate ?? "no location data")

        let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 10.0)
        self.mapView.mapboxMap.setCamera(to: cameraOptions)
        
        /*
        if let currentLocation = self.mapView.location.latestLocation {
            print("latestLocation")
            print(currentLocation.coordinate.latitude)
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066), zoom: 10.0)
            self.mapView.mapboxMap.setCamera(to: cameraOptions)
        }
         */
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingSource = .course
        
        initCompassButton()
    }
    
    func initCompassButton() {
        print("\(#function)")
        startCompassBtn = UIButton(frame: CGRect(x: 5,
                                                 y: view.bounds.height * 0.8,
                                           width: 100,
                                           height: 30))
        startCompassBtn.setTitleColor(.blue, for: .normal)
        startCompassBtn.isHidden = false
        startCompassBtn.setTitle("Start", for: .normal)
        startCompassBtn.addTarget(self, action: #selector(startCompass), for: .touchUpInside)
        
        view.addSubview(startCompassBtn)
        
        stopCompassBtn = UIButton(frame: CGRect(x: startCompassBtn.frame.origin.x,
                                                y: startCompassBtn.frame.origin.y + startCompassBtn.bounds.height + 5,
                                           width: 100,
                                           height: 30))
        
        stopCompassBtn.setTitleColor(.gray, for: .normal)
        stopCompassBtn.isHidden = false
        stopCompassBtn.setTitle("Stop", for: .normal)
        stopCompassBtn.addTarget(self, action: #selector(stopCompass), for: .touchUpInside)
        view.addSubview(stopCompassBtn)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        print (heading.magneticHeading)
        let new = CameraOptions(bearing:locationManager.heading?.magneticHeading)
        mapView.mapboxMap.setCamera(to: new)
    }
    
    func requstFullAccuracy(){
        self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
    }
    
    func initUI(){

        // Granularly configure the location puck with a `Puck2DConfiguration`
        let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        mapView.location.options.puckType = .puck2D(configuration)
        mapView.location.options.puckBearingSource = .course
        
        // Center map over the user's current location
        /*
         mapView.mapboxMap.onNext(.mapLoaded, handler: { [weak self] _ in
         guard let self = self else { return }
         
         if let currentLocation = self.mapView.location.latestLocation {
         print("onNext")
         let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 20.0)
         self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
         }
         })
         */
        
        // Accuracy ring is only shown when zoom is greater than or equal to 18
        mapView.mapboxMap.onEvery(.cameraChanged, handler: { [weak self] _ in
            guard let self = self else { return }
            //self.toggleAccuracyRadiusButton.isHidden = self.mapView.cameraState.zoom < 18.0
        })
    }
    

    
    @objc func startCompass() {
        locationManager.startUpdatingHeading()
    }
    
    @objc func stopCompass() {
        locationManager.stopUpdatingHeading()
    }
            
}

extension MapViewController: LocationPermissionsDelegate {
    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform an action in response to the new change in accuracy
            print("reducedAccuracy")
            //mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
            
        }
        if accuracyAuthorization == .fullAccuracy {
            print("fullAccuracy")
            initMap()
            
        }
    }
    
}



