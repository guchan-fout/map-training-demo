//
//  AdvancedViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/04/08.
//

import UIKit

import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps

var simulationIsEnabled = true

class AdvancedViewController: UIViewController, NavigationMapViewDelegate,CLLocationManagerDelegate, NavigationViewControllerDelegate {
    
    var navigationMapView: NavigationMapView!
    var naviService:MapboxNavigationService!
    var navigationRouteOptions: NavigationRouteOptions!
    
    internal var shrinkBtn: UIButton!
    internal var backBtn: UIButton!
    
    var currentRouteIndex = 0 {
        didSet {
            showCurrentRoute()
        }
    }
    var currentRoute: Route? {
        return routes?[currentRouteIndex]
    }
    
    var routes: [Route]? {
        return routeResponse?.routes
    }
    
    var routeResponse: RouteResponse!
    
    func showCurrentRoute() {
        guard let currentRoute = currentRoute else { return }
        
        var routes = [currentRoute]
        routes.append(contentsOf: self.routes!.filter {
            $0 != currentRoute
        })
        navigationMapView.show(routes)
        navigationMapView.showWaypoints(on: currentRoute)
    }
    
    var startButton: UIButton!
    
    // MARK: - UIViewController lifecycle methods
    
    internal var locationManager: CLLocationManager! =  CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationMapView.delegate = self
        navigationMapView.userLocationStyle = .courseView()
        
        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
        navigationViewportDataSource.options.followingCameraOptions.centerUpdatesAllowed = true
        navigationViewportDataSource.followingMobileCamera.zoom = 14.0
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        navigationMapView.addGestureRecognizer(gesture)
        
        view.addSubview(navigationMapView)
        
        startButton = UIButton()
        startButton.setTitle("Start Navigation", for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.backgroundColor = .blue
        startButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        startButton.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
        startButton.isHidden = true
        view.addSubview(startButton)
        
        startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.setNeedsLayout()
        
        
        shrinkBtn = UIButton(frame: CGRect(x: 5,
                                                 y: view.bounds.height * 0.65,
                                                 width: 100,
                                                 height: 30))
        shrinkBtn.setTitleColor(.blue, for: .normal)
        shrinkBtn.isHidden = false
        shrinkBtn.setTitle("Shrink", for: .normal)
        shrinkBtn.addTarget(self, action: #selector(startShrink), for: .touchUpInside)
        
        view.addSubview(shrinkBtn)
        
        backBtn = UIButton(frame: CGRect(x: 5,
                                                 y: view.bounds.height * 0.70,
                                                 width: 100,
                                                 height: 30))
        backBtn.setTitleColor(.blue, for: .normal)
        backBtn.isHidden = false
        backBtn.setTitle("Back", for: .normal)
        backBtn.addTarget(self, action: #selector(backToNormal), for: .touchUpInside)
        
        view.addSubview(backBtn)
        
        //here to get heading data from device
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
    
    @objc func startShrink () {
        navigationMapView.frame = CGRect(x: 0, y: 0, width: 300,height: 300)
    }
    
    @objc func backToNormal () {
        navigationMapView.frame = view.bounds
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // this two lines will set the bearing to the data you set
        // notice that the device's heading can be get from CLLocationManagerDelegate
        let cameraOptions = CameraOptions(bearing:newHeading.trueHeading)
        navigationMapView.mapView.mapboxMap.setCamera(to: cameraOptions)
        
    }
    
    // Override layout lifecycle callback to be able to style the start button.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        startButton.layer.cornerRadius = startButton.bounds.midY
        startButton.clipsToBounds = true
        startButton.setNeedsDisplay()
    }
    
    @objc func tappedButton(sender: UIButton) {
        
        self.naviService = MapboxNavigationService(routeResponse: self.routeResponse,
                                                   routeIndex: 0,
                                                   routeOptions: navigationRouteOptions,
                                                   simulating: true ? .always : .onPoorGPS)
        
        self.naviService.start()
        self.naviService.delegate = self
        
        
        return
        guard let routeResponse = routeResponse, let navigationRouteOptions = navigationRouteOptions else { return }
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        let navigationService = MapboxNavigationService(routeResponse: routeResponse,
                                                        routeIndex: currentRouteIndex,
                                                        routeOptions: navigationRouteOptions,
                                                        simulating: simulationIsEnabled ? .always : .onPoorGPS)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: currentRouteIndex,
                                                                routeOptions: navigationRouteOptions,
                                                                navigationOptions: navigationOptions)
        navigationViewController.delegate = self
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = navigationMapView.mapView.mapboxMap.coordinate(for: gesture.location(in: navigationMapView.mapView))
        
        requestRoute(destination: location)
    }
    
    func requestRoute(destination: CLLocationCoordinate2D) {
        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }
        
        let location = CLLocation(latitude: userLocation.coordinate.latitude,
                                  longitude: userLocation.coordinate.longitude)
        
        let userWaypoint = Waypoint(location: location,
                                    heading: userLocation.heading,
                                    name: "user")
        
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
        
        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else { return }
                
                self.navigationRouteOptions = navigationRouteOptions
                self.routeResponse = response
                self.startButton?.isHidden = false
                if let routes = self.routes,
                   let currentRoute = self.currentRoute {
                    self.navigationMapView.show(routes)
                    self.navigationMapView.showWaypoints(on: currentRoute)
                    
                    
                }
            }
        }
    }
    
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}


extension AdvancedViewController:NavigationServiceDelegate{
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        
        // Add maneuver arrow
        print("12222342")
        if progress.currentLegProgress.followOnStep != nil {
            navigationMapView.addArrow(route: progress.route, legIndex: progress.legIndex, stepIndex: progress.currentLegProgress.stepIndex + 1)
        } else {
            navigationMapView.removeArrow()
        }
        
        // Update the user puck
        navigationMapView.moveUserLocation(to: location, animated: true)
        
        navigationMapView.mapView.camera.ease(to: CameraOptions(center: location.coordinate, zoom: 15, bearing: location.course), duration: 1.0, curve: .linear)
        
    }
}
