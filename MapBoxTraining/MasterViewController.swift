//
//  MasterViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/03/07.
//

import UIKit
import MapboxMaps


class MasterViewController: UIViewController {
    
    internal var mapView: MapView!

   override func viewDidLoad() {
     setUpMap()
   }
   
   override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
   }
   
   
   func setUpMap() {
       let style1 = StyleURI(rawValue: "mapbox://styles/swgr/ckt0bz1l9atav18pskjeu75oo")
       let style2 = StyleURI(rawValue: "mapbox://styles/swgr/ckyixzuy93w1d14o8ysz02szt")
       
       let options = MapInitOptions(cameraOptions: CameraOptions(zoom: 10.0),styleURI: style2)
      
       mapView = MapView(frame: view.bounds, mapInitOptions: options)
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       view.addSubview(mapView)
     }
    

}
