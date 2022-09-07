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
        
        let left_top_point = CGPoint(x: view.frame.minX + 50, y:view.frame.minY + 50)
        let right_top_point = CGPoint(x: view.frame.maxX - 50, y:view.frame.minY + 50)
        let left_bottom_point = CGPoint(x: view.frame.minX + 50, y: view.frame.maxY - 50)
        let right_bottom_point = CGPoint(x: view.frame.maxX - 50, y: view.frame.maxY - 50)

        let left_top_coordi = mapView.mapboxMap.coordinate(for: left_top_point)
        let right_top_coordi = mapView.mapboxMap.coordinate(for: right_top_point)
        let left_bottom_coordi = mapView.mapboxMap.coordinate(for: left_bottom_point)
        let right_bottom_coordi = mapView.mapboxMap.coordinate(for: right_bottom_point)
        

        let ringCoords = [
            left_top_coordi,
            right_top_coordi,
            right_bottom_coordi,
            left_bottom_coordi,
            left_top_coordi
        ]
       
        
        let ring = Ring(coordinates: ringCoords)
        let polygon = Polygon(outerRing: ring)

        // Create a new polygon annotation using those coordinates.
        var polygonAnnotation = PolygonAnnotation(polygon: polygon)
        polygonAnnotation.fillColor = StyleColor(.blue)

        // Create the `PolygonAnnotationManager` which will be responsible for handling this annotation
        let polygonAnnotationManager = mapView.annotations.makePolygonAnnotationManager()

        // Add the polygon to the map as an annotation.
        polygonAnnotationManager.annotations = [polygonAnnotation]
        
        
        /*
        let bounds = mapView.mapboxMap.coordinateBoundsZoomUnwrapped(for: CameraOptions(cameraState: mapView.cameraState))
        let lineString = LineString([bounds.bounds.northeast, bounds.bounds.northwest, bounds.bounds.southwest, bounds.bounds.southeast, bounds.bounds.northeast])
        var annotation = PolylineAnnotation(lineString: lineString)
        
        annotation.lineColor = StyleColor(.red)
        annotationManager.annotations = [annotation]
        */
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
