//
//  CoordinateBoundsViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/09/02.
//

import UIKit
import MapboxMaps
import MapboxCoreMaps
import MapboxDirections

class CoordinateBoundsViewController: UIViewController {
    
    var mapView: MapView!
    var annotationManager: PolylineAnnotationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

                mapView = MapView(frame: view.bounds)
                mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
                   let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showBounds))
                   tapGestureRecognizer.delegate = self
                   self.mapView.addGestureRecognizer(tapGestureRecognizer)

                   self.annotationManager = self.mapView.annotations.makePolylineAnnotationManager()
               }
    }
    
    @objc func showBounds() {
        
        let bounds = mapView.mapboxMap.coordinateBoundsZoomUnwrapped(for: CameraOptions(cameraState: mapView.cameraState))
        let lineString = LineString([bounds.bounds.northeast, bounds.bounds.northwest, bounds.bounds.southwest, bounds.bounds.southeast, bounds.bounds.northeast])
        var annotation = PolylineAnnotation(lineString: lineString)
        
        annotation.lineColor = StyleColor(.red)
        annotationManager.annotations = [annotation]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension CoordinateBoundsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
