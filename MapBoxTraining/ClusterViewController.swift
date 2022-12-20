//
//  ClusterViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/12/07.
//

import UIKit
import MapboxMaps

class ClusterViewController: UIViewController {
    
    internal var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
        let cameraOptions = CameraOptions(center: center, zoom: 11)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addSymbolClusteringLayers()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addSymbolClusteringLayers() {
        let style = mapView.mapboxMap.style
        let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)
        try! style.addImage(image, id: "fire-station-icon", sdf: true)
        
        let image_crown = UIImage(named: "star")!
        try! style.addImage(image_crown, id: "crown")
        
        let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!
        
        // Create a GeoJSONSource using the previously specified URL.
        var source = GeoJSONSource()
        source.data = .url(url)
        
        // Enable clustering for this source.
        source.cluster = true
        source.clusterRadius = 75
        
        // here to get each point's feature, and check any of them are true, then the cluster's new parameter's value will be true
        let clusterProp: [String: Expression] = ["hasLowFlow": Exp(.any) {Exp(.lte){Exp(.get) { "FLOW" }; 100.0}}]
        
        let clusterProp1: [String: Expression] = ["hasLowFlow": Exp(.eq){Exp(.get) { "FLOW" }}]
        
        let clusterProp2: [String: Expression] = ["hasLowFlow": Exp(.all) { Exp(.get) { "FLOW" }}]
        
        
        
        
        let expCafe = Exp(.all) {Exp(.eq){Exp(.get) { "Category" }; "coffee"}}
        //let clusterPropCafe: [String: Expression] = ["isAllCafe": expCafe]
        
        let expBar = Exp(.all) {Exp(.eq){Exp(.get) { "Category" }; "bar"}}
        //let clusterPropBar: [String: Expression] = ["isAllBar": expBar]
        
        
        let combiExp = ["isAllCafe": expCafe,"isAllBar": expBar]
        
        source.clusterProperties = combiExp
        
        
        
        let sourceID = "fire-hydrant-source"
        
        var clusteredLayer = createClusteredLayer()
        clusteredLayer.source = sourceID
        
        var unclusteredLayer = createUnclusteredLayer()
        unclusteredLayer.source = sourceID
        
        // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
        var clusterCountLayer = createNumberLayer()
        clusterCountLayer.source = sourceID
        
        // Add the source and two layers to the map.
        try! style.addSource(source, id: sourceID)
        try! style.addLayer(clusteredLayer)
        try! style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
        try! style.addLayer(clusterCountLayer)
        
    }
    
    
    func createClusteredLayer() -> CircleLayer {
        // Create a symbol layer to represent the clustered points.
        var clusteredLayer = CircleLayer(id: "clustered-circle-layer")
        
        // Filter out unclustered features by checking for `point_count`. This
        // is added to clusters when the cluster is created. If your source
        // data includes a `point_count` property, consider checking
        // for `cluster_id`.
        clusteredLayer.filter = Exp(.has) { "point_count" }
        
        // Set the color of the icons based on the number of points within
        // a given cluster. The first value is a default value.
        
        clusteredLayer.circleColor = .expression(Exp(.step) {
            Exp(.get) { "point_count" }
            UIColor.systemGreen
            50
            UIColor.systemBlue
            100
            UIColor.systemRed
        })
        
        clusteredLayer.circleRadius = .constant(25)
        
        return clusteredLayer
    }
    
    func createUnclusteredLayer() -> SymbolLayer {
        // Create a symbol layer to represent the points that aren't clustered.
        var unclusteredLayer = SymbolLayer(id: "unclustered-point-layer")
        
        // Filter out clusters by checking for `point_count`.
        unclusteredLayer.filter = Exp(.not) {
            Exp(.has) { "point_count" }
        }
        unclusteredLayer.iconImage = .constant(.name("fire-station-icon"))
        unclusteredLayer.iconColor = .constant(StyleColor(.white))
        
        // Rotate the icon image based on the recorded water flow.
        // The `mod` operator allows you to use the remainder after dividing
        // the specified values.
        unclusteredLayer.iconRotate = .expression(Exp(.mod) {
            Exp(.get) { "FLOW" }
            360
        })
        
        return unclusteredLayer
    }
    
    func createNumberLayer() -> SymbolLayer {
        var numberLayer = SymbolLayer(id: "cluster-count-layer")
        
        // check whether the point feature is clustered
        numberLayer.filter = Exp(.has) { "point_count" }
        
        numberLayer.textSize = .constant(12)
        numberLayer.textColor = .constant(StyleColor(.lightGray))
        
        let iconExp =  Exp(.switchCase) { // Switching on a value
            Exp(.eq) { // Evaluates if conditions are equal
                Exp(.get) { "isAllBar" }
                true
            }
            "crown"
            "" // default case is to return an empty string so no icon will be loaded
        }
        numberLayer.textField = .expression(Exp(.get) { "point_count" })
        
        numberLayer.iconImage = .expression(iconExp)
        
        return numberLayer
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: mapView)
        
        
        
        
        // Look for features at the tap location within the clustered and
        // unclustered layers.
        mapView.mapboxMap.queryRenderedFeatures(with: point,
                                                options: RenderedQueryOptions(layerIds: ["unclustered-point-layer", "clustered-circle-layer"],
                                                                              filter: nil)) { [weak self] result in
            switch result {
            case .success(let queriedFeatures):
                // Return the first feature at that location, then pass attributes to the alert controller.
                // Check whether the feature has values for `ASSETNUM` and `LOCATIONDETAIL`. These properties
                // come from the fire hydrant dataset and indicate that the selected feature is not clustered.
                if let selectedFeatureProperties = queriedFeatures.first?.feature.properties,
                   case let .number(featureInformation) = selectedFeatureProperties["FLOW"],
                   case let .string(location) = selectedFeatureProperties["LOCATIONDETAIL"] {
                    self?.showAlert(withTitle: "Hydrant \(featureInformation)", and: "\(location)")
                    // If the feature is a cluster, it will have `point_count` and `cluster_id` properties. These are assigned
                    // when the cluster is created.
                } else if let selectedFeature = queriedFeatures.first?.feature,
                          case let .number(pointCount) = selectedFeature.properties?["point_count"],
                          case let .number(clusterId) = selectedFeature.properties?["cluster_id"] {
                    
                    do {
                        try self?.mapView.mapboxMap.style.updateLayer(withId: "clustered-circle-layer", type: CircleLayer.self, update: { (layer: inout CircleLayer) in
                            
                            // change clicked cluster's color
                            let unclickedColor = "#FFFAFA"
                            let clickedColor = "#7CFC00"
                            
                            let expColor = Exp(.switchCase){
                                Exp(.eq) {
                                    Exp(.get) {"cluster_id"}
                                    clusterId
                                }
                                clickedColor
                                unclickedColor
                            }
                            layer.circleColor = .expression(expColor)
                            
                            // change clicked cluster's cycle size
                            
                            let unclickedRadius = 25
                            let clickedRadius = 40
                            
                            let expCircle = Exp(.switchCase){
                                Exp(.eq) {
                                    Exp(.get) {"cluster_id"}
                                    clusterId
                                }
                                clickedRadius
                                unclickedRadius
                            }
                            layer.circleRadius = .expression(expCircle)
                           
                        })
                    } catch {
                        print("Updating the layer clustered-circle-layer failed: \(error.localizedDescription)")
                    }
                    
                    self?.mapView.mapboxMap.queryFeatureExtension(for: "fire-hydrant-source", feature: selectedFeature, extension: "supercluster", extensionField: "leaves") {
                        result in
                        switch result {
                        case .success(let features):
                            let feas = features.features
                            
                            for f in feas ?? [] {
                                print(f)
                            }
                            print(selectedFeature)
                            
                            //completion(.success(features))
                        case .failure(let error):
                            //completion(.failure(error))
                            print(error)
                        }
                    }
                    
                    self?.showAlert(withTitle: "Cluster ID \(Int(clusterId))", and: "There are \(Int(pointCount)) points in this cluster")
                }
            case .failure(let error):
                self?.showAlert(withTitle: "An error occurred: \(error.localizedDescription)", and: "Please try another hydrant")
            }
        }
    }
    
    func showAlert(withTitle title: String, and message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
