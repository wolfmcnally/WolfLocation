//
//  BeaconTelemetry.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import WolfCore

public struct BeaconTelemetry {
    public var uuid: UUID
    public var major: UInt16
    public var minor: UInt16
    public var proximity: CLProximity
    public var accuracy: CLLocationAccuracy
    public var rssi: Int

    public init(clBeacon: CLBeacon) {
        uuid = clBeacon.proximityUUID
        major = clBeacon.major.uint16Value
        minor = clBeacon.minor.uint16Value
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
    }
}

extension BeaconTelemetry {
    public var sortWeight: SortWeight {
        return .list([proximity.sortWeight, .double(accuracy >= 0 ? accuracy : veryFarAway)])
    }
}
