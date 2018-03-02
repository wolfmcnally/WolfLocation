//
//  Beacon.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import WolfCore

public struct Beacon {
    public let uuid: UUID
    public let major: UInt16
    public let minor: UInt16
    public let proximity: CLProximity
    public let accuracy: CLLocationAccuracy
    public let rssi: Int

    public init(clBeacon: CLBeacon) {
        uuid = clBeacon.proximityUUID
        major = clBeacon.major.uint16Value
        minor = clBeacon.minor.uint16Value
        proximity = clBeacon.proximity
        accuracy = clBeacon.accuracy
        rssi = clBeacon.rssi
    }
}

extension Beacon {
    public var sortWeight: SortWeight {
        return .list([proximity.sortWeight, .double(accuracy >= 0 ? accuracy : veryFarAway)])
    }
}
