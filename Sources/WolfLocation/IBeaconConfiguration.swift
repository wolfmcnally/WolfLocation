//
//  IBeaconConfiguration.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/9/18.
//

import Foundation

public struct IBeaconConfiguration: Codable {
    public var uuid: UUID
    public var major: UInt16
    public var minor: UInt16
}
