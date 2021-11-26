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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiY2hhbi1ndSIsImEiOiJja3ZjMGt0dXFhc3RhMndxNnR3M3o2bmgzIn0.iUfIljSfjBVpGu-FkbAIEw")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.location.delegate = self
        mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        //self.view.addSubview(mapView)
        
        LocationManager.shared.requestLocationAuthorization()
    }
    
    func requestPermissionsButtonTapped() {
        
    }
    
}

extension MapViewController: LocationPermissionsDelegate {
    private func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform an action in response to the new change in accuracy
            print("reducedAccuracy")
        }
        if accuracyAuthorization == .fullAccuracy {
            print("fullAccuracy")
            
        }
    }
    
}


class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?

    public func requestLocationAuthorization() {
        self.locationManager.delegate = self
        let currentStatus = CLLocationManager.authorizationStatus()

        // Only ask authorization if it was never asked before
        guard currentStatus == .notDetermined else { return }

        // Starting on iOS 13.4.0, to get .authorizedAlways permission, you need to
        // first ask for WhenInUse permission, then ask for Always permission to
        // get to a second system alert
        if #available(iOS 13.4, *) {
            self.requestLocationAuthorizationCallback = { status in
                if status == .authorizedWhenInUse {
                    self.locationManager.requestAlwaysAuthorization()
                }
            }
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallback?(status)
    }
}
