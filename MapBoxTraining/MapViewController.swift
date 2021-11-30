//
//  MapViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2021/11/25.
//

import UIKit
import MapboxMaps

class MapViewController: UIViewController {
    
    internal var mapView: MapView!
    internal let toggleAccuracyRadiusButton: UIButton = UIButton(frame: .zero)
    internal var showsAccuracyRing: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.location.delegate = self
        
        /*
        if (CLLocationManager().accuracyAuthorization == .fullAccuracy) {
            //print("now is reducedAccuracy ask for")
            //
        }else {
            //initMap()
        }
         */
    }
    
    func initMap() {
        print("initMap")
        print(CLLocationManager.init().location?.coordinate ?? "no location data")
       
        let cameraOptions = CameraOptions(center: CLLocationManager.init().location?.coordinate, zoom: 10.0)
        self.mapView.mapboxMap.setCamera(to: cameraOptions)

        if let currentLocation = self.mapView.location.latestLocation {
            print("latestLocation")
            print(currentLocation.coordinate.latitude)
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066), zoom: 10.0)
            self.mapView.mapboxMap.setCamera(to: cameraOptions)
        }
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        //let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingSource = .course
        
        //initUI()
    }
    
    func requstFullAccuracy(){
        self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
    }
    
    func initUI(){
        // Setup and create button for toggling accuracy ring
        setupToggleShowAccuracyButton()
        
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
            self.toggleAccuracyRadiusButton.isHidden = self.mapView.cameraState.zoom < 18.0
        })
    }
    
    @objc func showHideAccuracyRadius() {
        showsAccuracyRing.toggle()
    }
    
    func syncPuckAndButton() {
        // Update puck config
        var configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        configuration.showsAccuracyRing = showsAccuracyRing
        mapView.location.options.puckType = .puck2D(configuration)
        
        // Update button title
        let title: String = showsAccuracyRing ? "Disable Accuracy Radius" : "Enable Accuracy Radius"
        toggleAccuracyRadiusButton.setTitle(title, for: .normal)
    }
    
    private func setupToggleShowAccuracyButton() {
        // Styling
        toggleAccuracyRadiusButton.backgroundColor = .systemBlue
        toggleAccuracyRadiusButton.addTarget(self, action: #selector(showHideAccuracyRadius), for: .touchUpInside)
        toggleAccuracyRadiusButton.setTitleColor(.white, for: .normal)
        toggleAccuracyRadiusButton.isHidden = true
        syncPuckAndButton()
        toggleAccuracyRadiusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleAccuracyRadiusButton)
        
        // Constraints
        toggleAccuracyRadiusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleAccuracyRadiusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleAccuracyRadiusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 650.0).isActive = true
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



