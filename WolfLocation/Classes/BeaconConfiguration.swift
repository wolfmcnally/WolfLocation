//
//  BeaconConfiguration.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/9/18.
//

import WolfCore

public struct BeaconConfiguration: Codable {
    public var name: String?
    public var uuid: UUID
    public var major: UInt16
    public var minor: UInt16
    public var location: Point? // meters relative to site origin, nil if not on map
}
