//
//  BeaconRegion.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import WolfCore

public struct BeaconRegion: Codable {
    public let type = "BeaconConfig"
    public let subtype = "iBeacon"
    public let version = 1
    public let uuid: UUID
    public let major: UInt16?
    public let minor: UInt16?
    public let identifier: String

    public init(uuid: UUID, major: UInt16? = nil, minor: UInt16? = nil, identifier: String) {
        if minor != nil && major == nil {
            preconditionFailure("If minor is provided then major must also be provided.")
        }
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.identifier = identifier
    }

    public init(clBeaconRegion: CLBeaconRegion) {
        self.init(uuid: clBeaconRegion.proximityUUID, major: clBeaconRegion.major?.uint16Value, minor: clBeaconRegion.minor?.uint16Value, identifier: clBeaconRegion.identifier)
    }

    public static func makeRandom() -> BeaconRegion {
        let uuid = Lorem.uuid()
        let major = Random.number(UInt16.min ... UInt16.max)
        let minor = Random.number(UInt16.min ... UInt16.max)
        let identifier = Lorem.firstName()
        return BeaconRegion(uuid: uuid, major: major, minor: minor, identifier: identifier)
    }

    public func encodeToJSON() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }

    public static func decodeFromJSON(_ data: Data) throws -> BeaconRegion {
        let decoder = JSONDecoder()
        return try decoder.decode(self, from: data)
    }

    public var majorMinorDescription: String {
        let majorString = major != nil ? String(describing: major!) : "Any"
        let minorString = minor != nil ? String(describing: minor!) : "Any"
        return "Major: \(majorString) Minor: \(minorString)"
    }
}

extension BeaconRegion: Equatable {
    // This does *not* include the identifier. To compare for exact sameness,
    // including the identifier, use `BeaconRegion.isSame()`.
    public static func == (lhs: BeaconRegion, rhs: BeaconRegion) -> Bool {
        guard lhs.uuid == rhs.uuid else { return false }
        guard lhs.major == rhs.major else { return false }
        guard lhs.minor == rhs.minor else { return false }
        return true
    }
}

extension BeaconRegion: Hashable {
    public var hashValue: Int {
        var h = uuid.hashValue
        if let major = major { h += major.hashValue }
        if let minor = minor { h += minor.hashValue }
        return h
    }
}

extension BeaconRegion {
    public static func isSame(_ a: BeaconRegion, _ b: BeaconRegion) -> Bool {
        guard a == b else { return false }
        guard a.identifier == b.identifier else { return false }
        return true
    }
}

extension Set where Element == BeaconRegion {
    public func subtractingSame(_ b: Set<BeaconRegion>) -> Set<BeaconRegion> {
        return filter { aRegion in
            for bRegion in b {
                if BeaconRegion.isSame(aRegion, bRegion) {
                    return false
                }
            }
            return true
        }
    }
}

extension Sequence where Element == BeaconRegion {
    public func containsSame(_ e: Element) -> Bool {
        for aElement in self {
            if BeaconRegion.isSame(aElement, e) {
                return true
            }
        }
        return false
    }
}

extension Collection where Element == BeaconRegion {
    public func indexOfSame(_ e: Element) -> Index? {
        return index { BeaconRegion.isSame($0, e) }
    }
}

extension CLBeaconRegion {
    public convenience init(beaconRegion: BeaconRegion) {
        if let major = beaconRegion.major {
            if let minor = beaconRegion.minor {
                self.init(proximityUUID: beaconRegion.uuid, major: major, minor: minor, identifier: beaconRegion.identifier)
            } else {
                self.init(proximityUUID: beaconRegion.uuid, major: major, identifier: beaconRegion.identifier)
            }
        } else {
            self.init(proximityUUID: beaconRegion.uuid, identifier: beaconRegion.identifier)
        }
        self.notifyEntryStateOnDisplay = true
    }
}
