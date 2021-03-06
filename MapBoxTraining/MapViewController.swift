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
    internal var pitch: UIButton!
    internal var addAnnotation: UIButton!
    internal var moveAnnotation: UIButton!
    internal let annonationWidth:CGFloat = 85
    internal let annonationHeight:CGFloat = 35
    
    internal var cameraLocationConsumer: CameraLocationConsumer!
    
    internal let shangHaiHome = CLLocationCoordinate2D.init(latitude: 31.326055179625705, longitude: 121.45195437087595)
    
    internal let startCoordinate = CLLocationCoordinate2D.init(latitude: 35.68017841654902, longitude:  139.62552536616514)
    internal let endCoordinate = CLLocationCoordinate2D.init(latitude: 35.69657842654902, longitude:  139.62552536616514)
    internal var currentCoordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    internal var updateInterval: Double = 0.0
    
    private var displayLink: CADisplayLink? {
        didSet { oldValue?.invalidate() }
    }
    
    deinit {
        displayLink?.invalidate()
    }

    private let featureId = "some-feature-id"
    private var annotationView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = MapInitOptions(styleURI: StyleURI.dark)
        mapView = MapView(frame: view.bounds,mapInitOptions: options)
        mapView.location.delegate = self
        mapView.gestures.options.pitchEnabled = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        initMap()
        
    }
    
    func initMap() {
        print("initMap")
        print(CLLocationManager.init().location?.coordinate ?? "no location data")
        
        let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 12.0, pitch: 0)
        self.mapView.mapboxMap.setCamera(to: cameraOptions)
        
        //self.mapView.presentsWithTransaction = true
        
        
        
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
        
        //cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            // Register the location consumer with the map
            // Note that the location manager holds weak references to consumers, which should be retained
            print("send new location")
            //self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
            
        }
        
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingSource = .course
        
        initCompassButton()
        
        //self.addViewAnnotation(at:startCoordinate, name:"Here")
        /*
         self.addViewAnnotation(at:tempAnnonationLocation, name:"2222")
         
         if let coor = locationManager.location?.coordinate {
         self.addViewAnnotation(at: coor,name:"1111")
         
         }
         */
    }
    
    func initCompassButton() {
        print("\(#function)")
        
        //mapView.ornaments.options.scaleBar.margins = CGPoint(x: 100, y: 300)
        
        
        startCompassBtn = UIButton(frame: CGRect(x: 5,
                                                 y: view.bounds.height * 0.65,
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
        home.setTitle("ToShanghai", for: .normal)
        home.addTarget(self, action: #selector(flyToHome), for: .touchUpInside)
        view.addSubview(home)
        
        pitch = UIButton(frame: CGRect(x: home.frame.origin.x,
                                       y: home.frame.origin.y + home.bounds.height + 5,
                                       width: 100,
                                       height: 30))
        
        pitch.setTitleColor(.blue, for: .normal)
        pitch.isHidden = false
        pitch.setTitle("pitch", for: .normal)
        pitch.addTarget(self, action: #selector(changePitch), for: .touchUpInside)
        view.addSubview(pitch)
        
        addAnnotation = UIButton(frame: CGRect(x: pitch.frame.origin.x,
                                               y: pitch.frame.origin.y + pitch.bounds.height + 5,
                                               width: 150,
                                               height: 30))
        
        addAnnotation.setTitleColor(.white, for: .normal)
        addAnnotation.isHidden = false
        addAnnotation.setTitle("addAnnotation", for: .normal)
        addAnnotation.addTarget(self, action: #selector(addTempAnnotation), for: .touchUpInside)
        view.addSubview(addAnnotation)
        
        moveAnnotation = UIButton(frame: CGRect(x: pitch.frame.origin.x,
                                                y: addAnnotation.frame.origin.y + addAnnotation.bounds.height + 5,
                                                width: 150,
                                                height: 30))
        
        moveAnnotation.setTitleColor(.white, for: .normal)
        moveAnnotation.isHidden = false
        moveAnnotation.setTitle("updatePosition", for: .normal)
        moveAnnotation.addTarget(self, action: #selector(updatePosition(_:)), for: .touchUpInside)
        view.addSubview(moveAnnotation)
        
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
    
    @objc func changePitch(){
        //When use low level, toValue 0 also can reproduce the bug
        
        let animator = mapView.camera.makeAnimator(duration: 3, curve: .linear) { (transition) in
            transition.pitch.toValue = 0
        }
        animator.startAnimation()
        
        /*
         
         let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 5.0,pitch: 0)
         //self.mapView.mapboxMap.setCamera(to: cameraOptions)
         self.mapView.camera.ease(to: cameraOptions, duration: 5.0, curve: .linear, completion: nil)
         self.mapView.camera.fly(to: cameraOptions, duration: 5.0, completion: { result in
         if (result == .end) {
         }
         })
         */
        
    }
    
    @objc func flyToHome() {
        if (self.home.title(for: .normal) == "ToTokyo") {
            
            let cameraOptions = CameraOptions(center: locationManager.location?.coordinate, zoom: 5.0)
            //self.mapView.mapboxMap.setCamera(to: cameraOptions)
            self.mapView.camera.fly(to: cameraOptions, duration: 5.0, completion: { result in
                if (result == .end) {
                    self.home.setTitle("ToShanghai", for: .normal)
                }
            })
            
        } else {
            
            let newCamera = CameraOptions(center: shangHaiHome,zoom: 5.0,pitch: 0)
            self.mapView.camera.fly(to: newCamera, duration: 5.0, completion: { result in
                if (result == .end) {
                    self.home.setTitle("ToTokyo", for: .normal)
                }
            })
        }
    }
    
    
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D, name:String) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: annonationWidth,
            height: annonationHeight,
            associatedFeatureId: featureId,
            allowOverlap: true,
            anchor: .center
            
        )
        annotationView = createAnnotationView(withText: name)
        try? self.mapView.viewAnnotations.add(annotationView, options: options)
    }
    
    @objc func addTempAnnotation() {
        let newname = "Here"
        let options = ViewAnnotationOptions(
            geometry: Point(startCoordinate),
            width: annonationWidth,
            height: annonationHeight,
            allowOverlap: true,
            anchor: .center
            
        )
        annotationView = createAnnotationView(withText: newname)
        
        
        updateInterval = coodinateCalculator(startLocation: startCoordinate, endLocation: endCoordinate)
        var start = startCoordinate.latitude
        let end = endCoordinate.latitude
        UIView.transition(with: self.mapView, duration: 1.0, options: [.transitionCrossDissolve], animations: {
            try? self.mapView.viewAnnotations.add(self.annotationView, options: options)
        }, completion: { (finished: Bool) in
            /*
             Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
             if (start >= end) {timer.invalidate()}
             let temp = CLLocationCoordinate2D.init(latitude: start + interval, longitude:  self.endCoordinate.longitude)
             print("temp : %s",temp)
             let new_options = ViewAnnotationOptions(
             geometry: Point(temp),
             allowOverlap: true,
             anchor: .center
             )
             try? self.mapView.viewAnnotations.update(sampleView, options: new_options)
             start += interval
             }
             */
            
        })
    }
    
    @objc private func updateFromDisplayLink(displayLink: CADisplayLink) {
        
        guard (currentCoordinate.latitude <= endCoordinate.latitude) else {
            displayLink.invalidate()
            self.displayLink = nil
            return
        }
        
        // interpolate from origin to destination according to the animation progress
        currentCoordinate = CLLocationCoordinate2D(
            latitude: currentCoordinate.latitude + updateInterval,
            longitude:currentCoordinate.longitude
        )
        
        // update current position
        print("updateFromDisplayLink to :%s",currentCoordinate)
        
        let new_options = ViewAnnotationOptions(
            geometry: Point(currentCoordinate),
            allowOverlap: true,
            anchor: .center
        )
        try? self.mapView.viewAnnotations.update(annotationView, options: new_options)

    }
    
    @objc private func updatePosition(_ sender: UITapGestureRecognizer) {
        currentCoordinate = startCoordinate
        
        // add display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateFromDisplayLink(displayLink:)))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func coodinateCalculator(startLocation:CLLocationCoordinate2D,endLocation:CLLocationCoordinate2D)-> Double {
        let start = startLocation.latitude
        let end = endLocation.latitude
        
        let interval = (end-start)/50
        
        return interval
    }
    
    
    private func createAnnotationView(withText text: String) -> UIView {
        let image = UIImage(named: "red_pin")
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
        stackView.distribution = .fillEqually
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
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        // break reference cycle when moving away from screen
        if parent == nil {
            displayLink = nil
        }
    }
}

public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?
    
    init(mapView: MapView) {
        self.mapView = mapView
    }
    
    public func locationUpdate(newLocation: Location) {
        print("get new location:\(newLocation.location.debugDescription)")
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 1.3)
        
        
    }
}

