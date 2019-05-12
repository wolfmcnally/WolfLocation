//
//  LocationMonitor.swift
//  WolfLocation
//
//  Created by Wolf McNally on 6/30/17.
//  Copyright © 2017 WolfMcNally.com.
//

import CoreLocation
import Foundation
import WolfKit

#if canImport(UIKit)
import UIKit
#endif

public class LocationMonitor {
    private let locationManager: LocationManager
    public private(set) var recentLocations = [CLLocation]()
    private var isStarted: Bool = false

    public let locationUpdated = Event<LocationMonitor>()

    public var location: CLLocation? {
        didSet { locationUpdated.notify(self) }
    }

    public init(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyKilometer, distanceFilter: CLLocationDistance = kCLDistanceFilterNone) {
        locationManager = LocationManager()
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
    }

    #if os(macOS)
    public func start() {
        guard !isStarted else { return }

        isStarted = true

        locationManager.didUpdateLocations = { [unowned self] locations in
            self.recentLocations = locations
            self.onLocationUpdated?(self)
            //logTrace(locations)
        }

        //    locationManager.didChangeAuthorizationStatus = { authorizationStatus in
        //      print("authorizationStatus: \(authorizationStatus)")
        //    }
        //
        //    locationManager.didFail = { error in
        //      print("didFail: \(error)")
        //    }

        locationManager.startUpdatingLocation()
    }
    #endif

    #if os(iOS)
    public func start(from viewController: UIViewController) {
        guard !isStarted else { return }

        logger?.setGroup(.location)

        isStarted = true

        guard DeviceAccess.checkLocationWhenInUseAuthorized(from: viewController) else {
            logWarning("Unable to start monitoring location.", group: .location)
            return
        }

        locationManager.didChangeAuthorizationStatus = { [unowned self] status in
            logTrace("LocationMonitor.didChangeAuthorizationStatus: \(status).")
            switch status {
            case .notDetermined:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                self.locationManager.startMonitoringSignificantLocationChanges()
            case .denied, .restricted:
                break
            @unknown default:
                fatalError()
            }
        }

        locationManager.didFail = { [unowned self] status in
            self.location = nil
        }

        locationManager.didUpdateLocations = { [unowned self] locations in
            self.recentLocations = locations
            self.location = self.locationManager.location
        }

        locationManager.requestWhenInUseAuthorization()
    }
    #endif
}
