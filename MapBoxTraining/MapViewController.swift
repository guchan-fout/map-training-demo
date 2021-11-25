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
        
        
        self.view.addSubview(mapView)
    }
    
    func requestPermissionsButtonTapped() {
        
    }
    
}

extension MapViewController: LocationPermissionsDelegate {
    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform an action in response to the new change in accuracy
        }
    }
    
}
