//
//  NHDemoViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/09/13.
//

import UIKit
import MapboxMaps
import AVFoundation
import WebKit

class NHDemoViewController: UIViewController, CLLocationManagerDelegate {
    
    internal var mapView: MapView!
    internal var locationManager: CLLocationManager!
    internal var pointAnnotationManager: PointAnnotationManager!
    internal var streamView: UIView!
    var youtubeWebView: WKWebView!
    
    internal var playerItem: AVPlayerItem!
    internal var player: AVPlayer!
    var playerObserver: NSKeyValueObservation!
    
    internal let youtubeLiveSpot = CLLocationCoordinate2D.init(latitude: 37.36769437, longitude: -122.02676936)
    
    private var displayLink: CADisplayLink? {
        didSet { oldValue?.invalidate() }
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private let featureId_small = "camera-1-small"
    private let featureId_big = "camera-1-big"
    private let featureId_youtube_small = "camera-1-youtube-small"
    private let featureId_youtube_big = "camera-1-youtube-big"
    private var annotationView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = MapInitOptions(styleURI: StyleURI.light)
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
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            guard let coordinate = self.locationManager.location?.coordinate else { return }
            //self.addViewAnnotation(at: coordinate)
            self.addMarker(at: coordinate)
        }
    }
    
    func addStreamView() {
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveLinear, animations: {
            self.streamView = UIView(frame: CGRect(x: 0,y: self.view.frame.maxY/2+50, width: self.view.frame.width, height: self.view.frame.maxY-(self.view.frame.maxY/2+50)))
            self.streamView.backgroundColor = .lightGray
            self.streamView.alpha = 0.5
            self.view.addSubview(self.streamView)
        }, completion: nil)

        //addSteamVideo()
    }
    
    func hideStreamView() {
        UIView.transition(with: self.view, duration: 1.5, options: [.curveLinear], animations: {
            self.streamView.removeFromSuperview()
        }, completion: nil)    }
    
    func addSteamVideo() {
        let asset = AVAsset(url: URL(string: "https://static-assets.mapbox.com/mapbox-gl-js/drone.mp4")!)
        playerItem = AVPlayerItem(asset: asset)
        observePlayer(playerItem)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: streamView.frame.width, height: streamView.frame.height)
        playerLayer.videoGravity = .resizeAspectFill
        self.streamView.layer.addSublayer(playerLayer)
    }
    
    func addYoutubeStream(){
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        //configuration.requiresUserActionForMediaPlayback = false
        
        youtubeWebView = WKWebView(frame: streamView.bounds, configuration: configuration)
        youtubeWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        youtubeWebView.load(URLRequest(url: URL(string: "https://www.youtube.com/embed/Fb0imHesPEk?autoplay=1&mute=1")!))
        streamView.alpha = 1
        streamView.addSubview(youtubeWebView)
    
    }
    
    private func observePlayer(_ playerItem: AVPlayerItem) {
            playerObserver = playerItem.observe(\AVPlayerItem.status) { [weak self] (playerItem, _) in
                if playerItem.status == .readyToPlay {
                    print("play")
                    self?.streamView.alpha = 1
                    self?.player.play()
                    
                }
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        print (heading.magneticHeading)
        let new = CameraOptions(bearing:locationManager.heading?.magneticHeading)
        mapView.mapboxMap.setCamera(to: new)
    }
    
    func requstFullAccuracy(){
        self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        var customPointAnnotation = PointAnnotation(id: featureId_small, coordinate: coordinate)
        customPointAnnotation.image = .init(image: UIImage(named: "live_camera_small")!, name: "live_camera_small")
         
        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = [customPointAnnotation]
        pointAnnotationManager.delegate = self
        
        var youtubePointAnnotation = PointAnnotation(id: featureId_youtube_small, coordinate: youtubeLiveSpot)
        youtubePointAnnotation.image = .init(image: UIImage(named: "youtube_small")!, name: "youtube_small")
        pointAnnotationManager.annotations.append(youtubePointAnnotation)
        
    }
    
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        imageView.contentMode = .scaleAspectFit
        imageView.image = .init(named: "live_camera_small")
        
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: imageView.frame.width,
            height: imageView.frame.height,
            allowOverlap: false,
            anchor: .center
        )
        
        try? mapView.viewAnnotations.add(imageView, options: options)
    }
}

extension NHDemoViewController: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        
        guard let tappedAnnotation = annotations.first else { return }
        print("annotation id = " + tappedAnnotation.id)
        
        if let i = annotations.firstIndex(where: { $0.id == featureId_small }) {
            var coordi: LocationCoordinate2D!
            switch annotations[i].geometry {
            case .point(let point):
                coordi = point.coordinates
                print(point.coordinates)
            default:
                print("not point")
            }

            var customPointAnnotation = PointAnnotation(id: featureId_big, coordinate: coordi)
            customPointAnnotation.image = .init(image: UIImage(named: "live_camera_big")!, name: "live_camera_big")
            //pointAnnotationManager.annotations[i] = customPointAnnotationBig
            if let index = pointAnnotationManager.annotations.firstIndex(where: {$0.id == featureId_small}) {
                pointAnnotationManager.annotations[index] = customPointAnnotation
                
            }
            
            addStreamView()
            addSteamVideo()
        }
        
        
        if let i = annotations.firstIndex(where: { $0.id == featureId_big }) {
            var coordi: LocationCoordinate2D!
            switch annotations[i].geometry {
            case .point(let point):
                coordi = point.coordinates
                print(point.coordinates)
            default:
                print("not point")
            }

            var customPointAnnotation = PointAnnotation(id: featureId_small, coordinate: coordi)
            customPointAnnotation.image = .init(image: UIImage(named: "live_camera_small")!, name: "live_camera_small")
            //pointAnnotationManager.annotations[i] = customPointAnnotationSmall
            if let index = pointAnnotationManager.annotations.firstIndex(where: {$0.id == featureId_big}) {
                pointAnnotationManager.annotations[index] = customPointAnnotation
            }
            
            hideStreamView()
        }
        
        if let i = annotations.firstIndex(where: { $0.id == featureId_youtube_small }) {
            var coordi: LocationCoordinate2D!
            switch annotations[i].geometry {
            case .point(let point):
                coordi = point.coordinates
                print(point.coordinates)
            default:
                print("not point")
            }

            var customPointAnnotation = PointAnnotation(id: featureId_youtube_big, coordinate: coordi)
            customPointAnnotation.image = .init(image: UIImage(named: "youtube_big")!, name: "youtube_big")
            //pointAnnotationManager.annotations[i] = customPointAnnotationBig
            if let index = pointAnnotationManager.annotations.firstIndex(where: {$0.id == featureId_youtube_small}) {
                pointAnnotationManager.annotations[index] = customPointAnnotation
            }
            
            addStreamView()
            addYoutubeStream()
        }
        
        if let i = annotations.firstIndex(where: { $0.id == featureId_youtube_big }) {
            var coordi: LocationCoordinate2D!
            switch annotations[i].geometry {
            case .point(let point):
                coordi = point.coordinates
                print(point.coordinates)
            default:
                print("not point")
            }

            var customPointAnnotation = PointAnnotation(id: featureId_youtube_small, coordinate: coordi)
            customPointAnnotation.image = .init(image: UIImage(named: "youtube_small")!, name: "youtube_small")
            //pointAnnotationManager.annotations[i] = customPointAnnotationBig
            if let index = pointAnnotationManager.annotations.firstIndex(where: {$0.id == featureId_youtube_big}) {
                pointAnnotationManager.annotations[index] = customPointAnnotation
            }
            
            hideStreamView()
        }
         
         
    }

}


extension NHDemoViewController: LocationPermissionsDelegate {
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

