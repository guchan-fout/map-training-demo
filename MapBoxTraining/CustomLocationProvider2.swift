//
//  CustomLocationProvider.swift
//  MapBoxTraining
//
//  Created by Chan Gu on 2022/02/18.
//

import Foundation
import MapboxMaps

final class CustomLocationProvider: NSObject {

    let locationManager: CLLocationManager
    var locationProviderOptions: LocationOptions = .init()

    private weak var delegate: LocationProviderDelegate?

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        
    }
}

extension CustomLocationProvider: LocationProvider {
    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    var accuracyAuthorization: CLAccuracyAuthorization {
        if #available(iOS 14.0, *) {
            return locationManager.accuracyAuthorization
        } else {
            return .fullAccuracy
        }
    }

    var heading: CLHeading? {
        locationManager.heading
    }

    var headingOrientation: CLDeviceOrientation {
        get { locationManager.headingOrientation }
        set { locationManager.headingOrientation = newValue }
    }

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        if #available(iOS 14.0, *) {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }

    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }

    func dismissHeadingCalibrationDisplay() {
        locationManager.dismissHeadingCalibrationDisplay()
    }
}

extension CustomLocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        delegate?.locationProvider(self, didUpdateLocations: locations)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        print(#function)
        delegate?.locationProvider(self, didUpdateHeading: heading)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
        delegate?.locationProvider(self, didFailWithError: error)
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        delegate?.locationProviderDidChangeAuthorization(self)
    }
}


