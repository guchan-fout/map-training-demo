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
    
    let geoJSONDataSourceIdentifier = "geoJSON-data-source"
    let stationLayer = "station-layer"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let center = CLLocationCoordinate2D(latitude: 35.78735289961631, longitude:139.70111409343542)
        let cameraOptions = CameraOptions(center: center, zoom: 7.5, pitch: 0)
        var styleURI: StyleURI?
        if let url = URL(string: "mapbox://styles/chan-gu/ckytqtxkn000714p0lz2im82p") {
            styleURI = StyleURI(url: url)
        }
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: styleURI ?? .light)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
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
}
