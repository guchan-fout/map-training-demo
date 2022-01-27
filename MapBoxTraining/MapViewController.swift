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
    internal var home: UIButton!

    internal let annonationWidth:CGFloat = 100
    internal let annonationHeight:CGFloat = 35
    
    internal let shangHaiHome = CLLocationCoordinate2D.init(latitude: 31.326055179625705, longitude: 121.45195437087595)
    
    internal let tempAnnonationLocation = CLLocationCoordinate2D.init(latitude: 35.68017841654902, longitude:  139.62552536616514)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MapView(frame: view.bounds)
        mapView.location.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        initMap()

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
        
        self.addViewAnnotation(at:tempAnnonationLocation, name:"2222")
        
        if let coor = locationManager.location?.coordinate {
            self.addViewAnnotation(at: coor,name:"1111")
            
        }
}
    
    func initCompassButton() {
        print("\(#function)")
        startCompassBtn = UIButton(frame: CGRect(x: 5,
                                                 y: view.bounds.height * 0.7,
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
        
        stopCompassBtn.setTitleColor(.blue, for: .normal)
        stopCompassBtn.isHidden = false
        stopCompassBtn.setTitle("Stop", for: .normal)
        stopCompassBtn.addTarget(self, action: #selector(stopCompass), for: .touchUpInside)
        view.addSubview(stopCompassBtn)
        
        home = UIButton(frame: CGRect(x: stopCompassBtn.frame.origin.x,
                                                y: stopCompassBtn.frame.origin.y + startCompassBtn.bounds.height + 5,
                                           width: 100,
                                           height: 30))
        
        home.setTitleColor(.blue, for: .normal)
        home.isHidden = false
        home.setTitle("home", for: .normal)
        home.addTarget(self, action: #selector(flyToHome), for: .touchUpInside)
        view.addSubview(home)
        
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
        mapView.location.options.puckBearingSource = .heading
        
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
    
    @objc func flyToHome() {
        if (self.home.title(for: .normal) == "Back") {
            let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 10.0)
            self.mapView.mapboxMap.setCamera(to: cameraOptions)
            self.mapView.camera.fly(to: cameraOptions, duration: 2.0, completion: { result in
                if (result == .end) {
                    self.home.setTitle("Home", for: .normal)
                }
            })
        } else {
            let newCamera = CameraOptions(center: shangHaiHome)
            self.mapView.camera.ease(to: newCamera, duration: 5.0, curve: .easeInOut, completion: { result in
                if (result == .end) {
                    self.home.setTitle("Back", for: .normal)
                }
            })
        }
    }
   
    
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D, name:String) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: annonationWidth,
            height: annonationHeight,
            allowOverlap: true,
            anchor: .center
            
        )
        let sampleView = createAnnotationView(withText: name)
        try? mapView.viewAnnotations.add(sampleView, options: options)
    }
    
    private func createAnnotationView(withText text: String) -> UIView {
        let image = UIImage(named: "munchi.png")
        let iconView = UIImageView(frame:
                          CGRect(x: 0, y: 0, width: 35, height: 35))
           iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.backgroundColor = .darkGray
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
             
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: annonationWidth, height: annonationHeight))
        stackView.axis = .horizontal
        //stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(label)
        
        return stackView
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
    
    func locationManager(_ locationManager: LocationManager, didFailToLocateUserWithError error: Error) {
        print("\(#function) error:\(error)")
    }
}



