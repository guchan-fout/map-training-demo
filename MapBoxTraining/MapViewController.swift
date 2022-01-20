//
//  MapViewController.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2021/11/25.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    internal var downloadBtn: UIButton!
    internal var checkDownloadBtn: UIButton!
    internal var removeAll: UIButton!
    
    internal var mapView: MGLMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        view.addSubview(mapView)
        
        downloadBtn = UIButton(frame: CGRect(x: 25,y: 100, width: 100,height: 30))
        downloadBtn.setTitleColor(.blue, for: .normal)
        downloadBtn.isHidden = false
        downloadBtn.setTitle("download", for: .normal)
        downloadBtn.addTarget(self, action: #selector(downloadMap), for: .touchUpInside)
        view.addSubview(downloadBtn)
        
        checkDownloadBtn = UIButton(frame: CGRect(x: 25,y: 130, width: 100,height: 30))
        checkDownloadBtn.setTitleColor(.blue, for: .normal)
        checkDownloadBtn.isHidden = false
        checkDownloadBtn.setTitle("checkStatus", for: .normal)
        checkDownloadBtn.addTarget(self, action: #selector(checkStatus), for: .touchUpInside)
        view.addSubview(checkDownloadBtn)
        
        removeAll = UIButton(frame: CGRect(x: 25,y: 160, width: 100,height: 30))
        removeAll.setTitleColor(.blue, for: .normal)
        removeAll.isHidden = false
        removeAll.setTitle("remove ALL", for: .normal)
        removeAll.addTarget(self, action: #selector(removeAllMaps), for: .touchUpInside)
        view.addSubview(removeAll)
    }
    
    @objc func downloadMap() {
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.zoomLevel + 2)
        
        setupOfflinePackHandler()
        
        // Store some data for identification purposes alongside the downloaded resources.
        
        let userInfo = ["name": "\(region.bounds)"]
        do {
            let context = try NSKeyedArchiver.archivedData(withRootObject: userInfo, requiringSecureCoding: false)
            
            MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            // Start downloading.
            pack!.resume()
            print("download start:" + region.description )}
            } catch {
                fatalError("Can't encode data: \(error)")
            }
    }
    
    func setupOfflinePackHandler() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(offlinePackProgressDidChange),
                                               name: NSNotification.Name.MGLOfflinePackProgressChanged,
                                               object: nil)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // Create point to represent where the symbol should be placed
        let point = MGLPointAnnotation()
        point.coordinate = mapView.centerCoordinate
        
        // Create a data source to hold the point data
        let shapeSource = MGLShapeSource(identifier: "marker-source", shape: point, options: nil)
        
        // Create a style layer for the symbol
        let shapeLayer = MGLSymbolStyleLayer(identifier: "marker-style", source: shapeSource)
        
        // Add the image to the style's sprite
        if let image = UIImage(named: "house-icon") {
            style.setImage(image, forName: "home-symbol")
        }
        
        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: "home-symbol")
        
        // Add the source and style layer to the map
        style.addSource(shapeSource)
        style.addLayer(shapeLayer)
    }
    
    @objc func checkStatus() {
        if let packs = MGLOfflineStorage.shared.packs {
            for pack in packs {
                print(pack.description + pack.state.rawValue.description)
            }
        }
    }
    
    @objc func removeAllMaps() {
        if let packs = MGLOfflineStorage.shared.packs {
            for pack in packs{
                print(pack.description + pack.state.rawValue.description)
                MGLOfflineStorage.shared.removePack(pack, withCompletionHandler: nil)
                //if (pack.state == .complete) {}
            }
        }
    }
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        /**
         Get the offline pack this notification is referring to,
         along with its associated metadata.
         */
        if let pack = notification.object as? MGLOfflinePack {
            
            if pack.state == .active {
                if (pack.progress.percentCompleted > 50) {
                    pack.suspend()
                    print("suspend download for \(pack.description)")
                }
            }
            
            if pack.state == .inactive {
                print("\(pack.description) is not downloading")
            }
            
            if pack.state == .complete {
                print("download completed")
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MGLOfflinePackProgressChanged,
                                                          object: nil)
            }
        }
        // Reload the table to update the progress percentage for each offline pack.
        //self.tableView.reloadData()
        
    }
}

fileprivate extension MGLOfflinePackProgress {
    var percentCompleted: Float {
        let percentage = Float(countOfResourcesCompleted) / Float(countOfResourcesExpected) * 100
        return percentage
    }
    
    var formattedCountOfBytesCompleted: String {
        return ByteCountFormatter.string(fromByteCount: Int64(countOfBytesCompleted),
                                         countStyle: .memory)
    }
}


