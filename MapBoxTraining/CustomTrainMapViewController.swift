//
//  CustomTrainMapViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/02/07.
//

import UIKit
import MapboxMaps

class CustomTrainMapViewController: UIViewController {
    internal var mapView: MapView!
    internal var locationManager: CLLocationManager!
    internal var showStation: UIButton!
    internal var query: UIButton!
    internal var showOneStation: UIButton!
    internal var combineFilter: Expression!
    
    let geoJSONDataSourceIdentifier = "geoJSON-data-source"
    let stationLayer = "station-layer"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let center = CLLocationCoordinate2D(latitude: 35.697543, longitude:139.591542)
        //let center = CLLocationCoordinate2D(latitude: -13.517379, longitude: -71.977221)
        
        let cameraOptions = CameraOptions(center: center, zoom: 13.5, pitch: 0)
        var styleURI: StyleURI?
        if let url = URL(string: "mapbox://styles/chan-gu/clblxljfl000116l3torih47m") {
            styleURI = StyleURI(url: url)
        }
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: styleURI ?? .light)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapClickY)))
        
        view.addSubview(mapView)
        mapView.gestures.delegate = self
        
        mapView.mapboxMap.onNext(.mapLoaded)  { _ in
            //self.setStationData()
        }
        
        showStation = UIButton(frame: CGRect(x: 5, y: 200, width: 100, height: 30))
        showStation.setTitleColor(.blue, for: .normal)
        showStation.isHidden = false
        showStation.setTitle("showStation", for: .normal)
        showStation.addTarget(self, action: #selector(showAllStation), for: .touchUpInside)
        view.addSubview(showStation)
        
        query = UIButton(frame: CGRect(x: 5, y: 300, width: 100, height: 30))
        query.setTitleColor(.blue, for: .normal)
        query.isHidden = false
        query.setTitle("query", for: .normal)
        query.addTarget(self, action: #selector(queryTile), for: .touchUpInside)
        view.addSubview(query)
        
        showOneStation = UIButton(frame: CGRect(x: 5, y: 400, width: 100, height: 30))
        showOneStation.setTitleColor(.blue, for: .normal)
        showOneStation.isHidden = false
        showOneStation.setTitle("show one satation", for: .normal)
        showOneStation.addTarget(self, action: #selector(showJustOneStation), for: .touchUpInside)
        view.addSubview(showOneStation)
    }
    
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }
        let filePath = URL(fileURLWithPath: path)
        var featureCollection: FeatureCollection?
        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        
        return featureCollection
    }
    
    internal func decodeFeatureGeoJSON(from fileName: String) throws -> Feature? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }
        let filePath = URL(fileURLWithPath: path)
        var feature: Feature?
        do {
            let data = try Data(contentsOf: filePath)
            feature = try JSONDecoder().decode(Feature.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        return feature
    }
    
    internal func setStationData() {
        // Attempt to decode GeoJSON from file bundled with application.
        guard let featureCollection = try? decodeGeoJSON(from: "N02-20_Station") else { return }
        
        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)
        geoJSONSource.lineMetrics = true // MUST be `true` in order to use `lineGradient` expression
        
        // Create a line layer
        var lineLayer = LineLayer(id: stationLayer)
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        
        // Setting the source
        lineLayer.source = geoJSONDataSourceIdentifier
        
        // Styling the line
        lineLayer.lineColor = .constant(StyleColor(.red))
        
        //lineLayer.lineWidth
        let lowZoomWidth = 0
        let highZoomWidth = 20
        lineLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                1
                lowZoomWidth
                30
                highZoomWidth
            }
        )
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)
        
        var symbolLayer = SymbolLayer(id: "station_name")
        symbolLayer.source = geoJSONDataSourceIdentifier
        // Set some style properties
        // "city_name" refers to a data property for features in the
        // source data
        
        symbolLayer.textField = .expression(Exp(.get) { "N02_005" })
        symbolLayer.textSize = .constant(12)
        symbolLayer.textColor = .constant(StyleColor(.orange))
        
        // Add the source and style layer to the map style.
        try! mapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
        try! mapView.mapboxMap.style.addLayer(lineLayer, layerPosition: nil)
        try! mapView.mapboxMap.style.addLayer(symbolLayer)
        
        addTapGesture(to: mapView)
        //addStationName(featureCollection: featureCollection)
    }
    
    public func addTapGesture(to mapView: MapView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(queryTile))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    
    func addStationName(feature:Feature) {
        switch feature.geometry {
        case .multiLineString(let line):
            
            let arr = line.coordinates.map { $0 }
            let center = geographicMidpoint(betweenCoordinates: arr[0])
            let data = feature.properties?["N02_005"]
            
            switch data {
            case .string(let inforamtion):
                addViewAnnotation(at: center, name: String(inforamtion))
            default:break
            }
            //print(data?.debugDescription)
            //let stationName =
            
            
            //addViewAnnotation(at: center, name: )
        default:break
        }
        
    }
    
    @objc func showAllStation() {
        setStationData()
    }
    
    
    
    @objc func queryTile(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)
        
        mapView.mapboxMap.queryRenderedFeatures(
            at: tapPoint,
            options: RenderedQueryOptions(layerIds: [stationLayer], filter: nil)) { [weak self] result in
                switch result {
                case .success(let queriedfeatures):
                    if let firstFeature = queriedfeatures.first?.feature.properties,
                       case let .string(stateName) = firstFeature["N02_003"] {
                        self?.showAlert(with: "You selected \(stateName)")
                    }
                case .failure(let error):
                    self?.showAlert(with: "An error occurred: \(error.localizedDescription)")
                }
            }
    }
    
    @objc func showJustOneStation() {
        
        guard let feature = try? decodeFeatureGeoJSON(from: "sample") else { return }
        addStationName(feature: feature)
        
    }
    
    public func showAlert(with title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    //I copied these codes from https://stackoverflow.com/questions/10559219/determining-midpoint-between-2-coordinates
    func geographicMidpoint(betweenCoordinates coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        
        guard coordinates.count > 1 else {
            return coordinates.first ?? // return the only coordinate
            CLLocationCoordinate2D(latitude: 0, longitude: 0) // return null island if no coordinates were given
        }
        
        var x = Double(0)
        var y = Double(0)
        var z = Double(0)
        
        for coordinate in coordinates {
            let lat = coordinate.latitude.toRadians()
            let lon = coordinate.longitude.toRadians()
            x += cos(lat) * cos(lon)
            y += cos(lat) * sin(lon)
            z += sin(lat)
        }
        
        x /= Double(coordinates.count)
        y /= Double(coordinates.count)
        z /= Double(coordinates.count)
        
        let lon = atan2(y, x)
        let hyp = sqrt(x * x + y * y)
        let lat = atan2(z, hyp)
        
        return CLLocationCoordinate2D(latitude: lat.toDegrees(), longitude: lon.toDegrees())
    }
    
    private func createAnnotationText(withText text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        return label
    }
    
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D, name:String) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: 100,
            height: 40,
            allowOverlap: false,
            anchor: .center
        )
        let sampleView = createAnnotationText(withText: name)
        try? mapView.viewAnnotations.add(sampleView, options: options)
    }
    
    @objc private func onMapClick(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let clickPoint = sender.location(in: mapView)
        let clickCoordinate = mapView.mapboxMap.coordinate(for: clickPoint)
        var feature = Feature(geometry: Point(clickCoordinate))
        print(feature)
        //filterPoiLabelss(feature: feature)
        filterPoiLabels(feature: feature)
    }
    
    @objc private func onMapClickY(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        
        /*
        do {
            

            
            
            let sourceIdentifier = "yjsource"
            var source = VectorSource()
            source.url = "mapbox://styles/chan-gu/clblxljfl000116l3torih47m"
            // Add the vector source to the style
            try mapView.mapboxMap.style.addSource(source, id: sourceIdentifier)
            
                        
            let expression = Exp(.switchCase) { // Switching on a value
                Exp(.gte) {
                    Exp(.get) { "point" }
                    3
                }
                "#A52A2A"
                "#8B0000"
                
            }
            
            var yjLayer = SymbolLayer(id: "yjlayer")
            yjLayer.source = sourceIdentifier
            yjLayer.sourceLayer = "yjtest"
            yjLayer.textField = .expression(Exp(.get) {"name"})
            yjLayer.textSize = .constant(12)
            yjLayer.textColor = .expression(expression)
            yjLayer.visibility = .constant(.visible)
            try mapView.mapboxMap.style.addLayer(yjLayer)
             
            
        } catch {
            print("Ran into an error adding source or layer: \(error)")
        }
             */
        
         do {
         let b = try? mapView.mapboxMap.style.layerProperties(for:"yjtest")
         print(b)
         
         try mapView.mapboxMap.style.updateLayer(withId: "yjtest", type: SymbolLayer.self) { layer in
         print(layer.filter)
         }
         
         let c = try? mapView.mapboxMap.style.layerProperties(for:"yjtest")
         print(c)
         
         } catch {
         print("update layer error: \(error)")
         }
         
    }
    
    func filterPoiLabelss(feature: Feature) {
        let style = mapView.mapboxMap.style
        let center = mapView.mapboxMap.cameraState.center
        //let center = CLLocationCoordinate2D(latitude: 35.70331432037365, longitude: 139.5906881364699)
        var point: Turf.Feature!
        point = Feature(geometry: Point(center))
        
        
        do {
            // Update the `SymbolLayer` with id "poi-label". This layer is included in the Mapbox
            // Streets v11 style. In order to see all layers included with your style, either inspect
            // the style in Mapbox Studio or inspect the `style.allLayerIdentifiers` property once
            // the style has finished loading.
            try style.updateLayer(withId: "poi-label", type: SymbolLayer.self) { (layer: inout SymbolLayer) throws in
                // Filter the "poi-label" layer to only show points less than 150 meters away from the
                // the specified feature.
                layer.filter = Exp(.lt) {
                    Exp(.distance) {
                        // Specify the feature that will be used as an anchor for the distance check.
                        // This feature should be a `GeoJSONObject`.
                        GeoJSONObject.feature(point)
                    }
                    // Specify the distance in meters that you would like to limit visible POIs to.
                    // Note that this checks the distance of the feature itself.
                    150
                }
            }
        } catch {
            print("Updating the layer failed: \(error.localizedDescription)")
        }
        
    }
    
    
    
    func filterPoiLabels(feature: Feature) {
        let style = mapView.mapboxMap.style
        
        do {
            try style.updateLayer(withId: "traffic-signal-high", type: SymbolLayer.self) { (layer: inout SymbolLayer) throws in
                
                let existedFilter = layer.filter
                let newFilter = Exp(.lt) {
                    Exp(.distance) {
                        GeoJSONObject.feature(feature)
                    }
                    150
                }
                
                combineFilter = Exp(.all) {
                    existedFilter!
                    newFilter
                }
                
                layer.filter = combineFilter
                //layer.filter = newFilter
            }
        } catch {
            print("Updating the layer failed: \(error.localizedDescription)")
        }
        print(combineFilter)
        
    }
}

extension CustomTrainMapViewController: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        
    }
    
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        
    }
    
    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        print("\(gestureType) didEnd")
        if (gestureType == .pan) {
            try? mapView.mapboxMap.style.addImage(UIImage(named: "live_camera_small")!,
                                                 id: "cameralive",
                                                 stretchX: [],
                                                 stretchY: [])
            try? mapView.mapboxMap.style.addImage(UIImage(named: "youtube_small")!,
                                                 id: "camerayoutube",
                                                 stretchX: [],
                                                 stretchY: [])
            
            let expression = Exp(.switchCase) { // Switching on a value
                Exp(.gte) {
                    Exp(.get) { "point" }
                    3
                }
                "camerayoutube"
                "cameralive"
            }
            
            if let data = try? JSONEncoder().encode(expression.self),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                try! mapView.mapboxMap.style.setLayerProperty(for: "yjlayer",
                                                              property: "icon-image",
                                                              value: jsonObject)
            }
            
            let expression2 = Exp(.switchCase) { // Switching on a value
                Exp(.gte) {
                    Exp(.get) { "point" }
                    3
                }
                "#A52A2A"
                "#8B0000"
            }
            
            if let data2 = try? JSONEncoder().encode(expression2.self),
               let jsonObject2 = try? JSONSerialization.jsonObject(with: data2, options: []) {
                try! mapView.mapboxMap.style.setLayerProperty(for: "yjlayer",
                                                              property: "text-color",
                                                              value: jsonObject2)
            }
        }
    }
}
