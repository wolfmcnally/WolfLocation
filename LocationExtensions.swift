//
//  LocationExtensions.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import WolfCore

extension CLRegionState {
    public var sortWeight: SortWeight {
        switch self {
        case .inside:
            return .int(0)
        case .unknown:
            return .int(1)
        case .outside:
            return .int(0)
        }
    }
}

extension CLProximity {
    public var sortWeight: SortWeight {
        switch self {
        case .immediate:
            return .int(0)
        case .near:
            return .int(1)
        case .far:
            return .int(2)
        case .unknown:
            return .int(3)
        }
    }
}
