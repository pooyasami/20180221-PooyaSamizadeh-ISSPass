//
//  AppDelegate.swift
//  ISSPassTime
//
//  Created by Pooya Samizadeh on 2018-02-20.
//  Copyright © 2018 Pooya Samizadeh. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()
    var locationTimer: Timer?
    var currentLocation: CLLocation?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.initializeLocationManager()
        self.startUpdatingLocation()
        
        return true
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    enum LocationManagerError {
        case NotFound
        case NoPremission
    }
    
    /// this method starts the timer and starts the location manager as well
    func startUpdatingLocation() {
        locationTimer?.invalidate()
        locationTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(locationTimerEnded(sender:)), userInfo: nil, repeats: false)
        self.locationManager.startUpdatingLocation()
    }
    
    @objc func locationTimerEnded(sender: Timer) {
        // if the current location is not available we handle the error cases, otherwise we send a notification
        // to notify our views to consume the current location
        if self.currentLocation != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
        } else {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: LocationManagerError.NoPremission)
            } else {
                // something went wrong
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: LocationManagerError.NotFound)
            }
        }
    }
    
    /// Initializes the location manager and also asks for the permission
    fileprivate func initializeLocationManager() {
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        
        // Override point for customization after application launch.
        locationManager.requestWhenInUseAuthorization()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
    }
    
    /// we only set the current location here since we have a timer for reading the last location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.startUpdatingLocation()
        }
    }
}
