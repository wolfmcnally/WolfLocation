//
//  BeaconRangingInfo.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import WolfConcurrency
import WolfFoundation

public class BeaconRangingInfo {
    private typealias `Self` = BeaconRangingInfo

    public let region: BeaconRegion

    public var state: CLRegionState = .unknown {
        didSet { didChange.notify(self) }
    }

    private var enteredRegionsDidChangeObserver: Event<(BeaconRegion, CLRegionState)>.Observer!
    private var didRangeBeaconObserver: Event<(BeaconTelemetry, BeaconRegion)>.Observer!
    private var lastRangingInfoDate: Date?
    private var staleTimerCanceler: Cancelable!

    public init(region: BeaconRegion) {
        //    init(region: BeaconRegion, state: CLRegionState) {
        self.region = region
        //        self.state = state
        enteredRegionsDidChangeObserver = beaconDetector.enteredRegionsDidChange.add { [unowned self] (region, state) in
            self.enteredRegionsDidChange(region, state: state)
        }
        didRangeBeaconObserver = beaconDetector.didRangeBeacon.add { [unowned self] (info, region) in
            self.didRangeBeacon(info, in: region)
            self.lastRangingInfoDate = Date()
        }
        staleTimerCanceler = dispatchRepeatedOnMain(atInterval: 5.0) { [unowned self] _ in
            guard let lastRangingInfoDate = self.lastRangingInfoDate else { return }
            if (lastRangingInfoDate.timeIntervalSinceReferenceDate - Date.timeIntervalSinceReferenceDate) > 2.5 {
                self.didRangeBeacon(nil, in: self.region)
            }
        }
    }

    deinit {
        enteredRegionsDidChangeObserver.invalidate()
        didRangeBeaconObserver.invalidate()
        staleTimerCanceler.cancel()
    }

    public static let maxInfosCount = 60

    public let didChange = Event<BeaconRangingInfo>()
    public private(set) var infos = [BeaconTelemetry?]()

    private func enteredRegionsDidChange(_ region: BeaconRegion, state: CLRegionState) {
        guard self.region == region else { return }
        self.state = state
    }

    private func didRangeBeacon(_ info: BeaconTelemetry?, in region: BeaconRegion) {
        guard self.region == region else { return }
        defer { didChange.notify(self) }

        if let info = info {
            if info.accuracy < 0 {
                infos.append(nil)
            } else {
                infos.append(info)
            }
        } else {
            infos.append(nil)
        }

        let dropCount = max(infos.count - Self.maxInfosCount, 0)
        guard dropCount > 0 else { return }
        infos = Array(infos.dropFirst(dropCount))
    }

    public var lastInfo: BeaconTelemetry? {
        guard let lastInfo = infos.last else {
            return nil
        }
        return lastInfo
    }

    private var lastInfoSortWeight: SortWeight {
        guard let lastInfo = lastInfo else {
            return .list([CLProximity.unknown.sortWeight, .double(veryFarAway)])
        }

        guard lastInfo.proximity != .unknown else {
            return .list([CLProximity.unknown.sortWeight, .double(veryFarAway)])
        }

        return lastInfo.sortWeight
    }

    public var sortWeight: SortWeight {
        return .list([lastInfoSortWeight, state.sortWeight])
    }
}
