//
//  BeaconDetector.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreBluetooth
import CoreLocation
import WolfCore

let beaconDetector = BeaconDetector()

extension UserDefaultsKey {
    static let trackedBeaconRegions = UserDefaultsKey("trackedBeaconRegions")
}

class BeaconDetector: NSObject {
    private typealias `Self` = BeaconDetector

    private let clLocationManager = CLLocationManager()
    let enteredRegionsDidChange = Event<(BeaconRegion, CLRegionState)>()
    let didRangeBeacon = Event<(Beacon, BeaconRegion)>()

    private static var _trackedRegions: [BeaconRegion]? = nil
    var trackedRegions: [BeaconRegion] {
        get {
            if Self._trackedRegions == nil {
                Self._trackedRegions = userDefaults[.trackedBeaconRegions] ?? []
            }
            return Self._trackedRegions!
        }

        set {
            Self._trackedRegions = newValue
            userDefaults[.trackedBeaconRegions] = newValue
            syncFromTrackedRegions()
        }
    }

    //    private var stateReqestTimerCanceler: Cancelable!
    //
    //    func startStateRequestTimer() {
    //        stateReqestTimerCanceler = dispatchRepeatedOnMain(atInterval: 10) { [unowned self] _ in
    //            self.issueStateRequests()
    //        }
    //    }

    private func issueStateRequests() {
        self.trackedRegions.forEach {
            self.clLocationManager.requestState(for: CLBeaconRegion(beaconRegion: $0))
        }
    }

    public func start() {
        //        reset()

        clLocationManager.delegate = self
        syncFromTrackedRegions()
        //        startStateRequestTimer()
        issueStateRequests()
    }

    fileprivate override init() {
        super.init()
    }

    public func reset() {
        for region in trackedRegions {
            clLocationManager.stopRangingBeacons(in: CLBeaconRegion(beaconRegion: region))
        }

        for region in trackedRegions {
            clLocationManager.stopMonitoring(for: CLBeaconRegion(beaconRegion: region))
        }
    }

    private func startMonitoring(for region: BeaconRegion) {
        logInfo("startMonitoring: \(region.identifier)")
        clLocationManager.startMonitoring(for: CLBeaconRegion(beaconRegion: region))
    }

    private func stopMonitoring(for region: BeaconRegion) {
        stopRanging(region: region)
        logInfo("stopMonitoring: \(region.identifier)")
        clLocationManager.stopMonitoring(for: CLBeaconRegion(beaconRegion: region))
    }

    private var monitoredRegions: Set<BeaconRegion> {
        var s = Set<BeaconRegion>()
        clLocationManager.monitoredRegions.forEach {
            guard let clBeaconRegion = $0 as? CLBeaconRegion else { return }
            s.insert(BeaconRegion(clBeaconRegion: clBeaconRegion))
        }
        return s
    }

    private var rangedRegions: Set<BeaconRegion> {
        var s = Set<BeaconRegion>()
        clLocationManager.rangedRegions.forEach {
            guard let clBeaconRegion = $0 as? CLBeaconRegion else { return }
            s.insert(BeaconRegion(clBeaconRegion: clBeaconRegion))
        }
        return s
    }

    private func syncFromTrackedRegions() {
        guard CLLocationManager.locationServicesEnabled() else {
            logWarning("Location Services is not enabled.")
            return
        }

        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
            logWarning("Monitoring beacons is not available on this device.")
            return
        }

        guard CLLocationManager.isRangingAvailable() else {
            logWarning("Ranging beacons is not available on this device.")
            return
        }

        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse else {
            clLocationManager.requestAlwaysAuthorization()
            return
        }

        let currentRegions = monitoredRegions
        let newRegions = Set(trackedRegions)

        let exitingRegions = currentRegions.subtractingSame(newRegions)
        let enteringRegions = newRegions.subtractingSame(currentRegions)

        exitingRegions.forEach { stopMonitoring(for: $0) }
        enteringRegions.forEach { startMonitoring(for: $0) }

        trackedRegions.forEach { startRanging(region: $0) }
    }

    private var enteredRegionIdentifiers: String {
        return "[" + (clLocationManager.monitoredRegions.map { $0.identifier }).joined(separator: ", ") + "]"
    }

    private func setState(_ state: CLRegionState, for region: BeaconRegion) {
        enteredRegionsDidChange.notify((region, state))
    }

    private func startRanging(region: BeaconRegion) {
        guard !rangedRegions.containsSame(region) else { return }
        clLocationManager.startRangingBeacons(in: CLBeaconRegion(beaconRegion: region))
        logInfo("💙💙 didStartRanging: \(region.identifier)")
    }

    private func stopRanging(region: BeaconRegion) {
        guard rangedRegions.containsSame(region) else { return }
        clLocationManager.stopRangingBeacons(in: CLBeaconRegion(beaconRegion: region))
        logInfo("❌❌ didStopRanging: \(region.identifier)")
    }

    private func didRange(beacon: Beacon, in region: BeaconRegion) {
        //        var message = "💜 \(region.identifier): \(beacon.proximity)"
        //        if beacon.proximity != .unknown {
        //            message += " ±\(beacon.accuracy %% 1) dB: \(beacon.rssi)"
        //        }
        //        logInfo(message)

        didRangeBeacon.notify((beacon, region))
    }

    private func didDetermineState(_ state: CLRegionState, for region: BeaconRegion) {
        let symbol: String
        switch state {
        case .inside:
            symbol = "✳️ inside"
        case .outside:
            symbol = "🛑 outside"
        case .unknown:
            symbol = "⚪️ unknown"
        }
        logTrace("\(Date()): \(symbol) \(region.identifier)")
        setState(state, for: region)
    }
}

extension BeaconDetector: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let region = region as? CLBeaconRegion else { return }
        didDetermineState(state, for: BeaconRegion(clBeaconRegion: region))
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        logError("monitoringDidFailFor: \(region!.identifier) \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        guard beacons.count > 0 else { return }
        for beacon in beacons {
            didRange(beacon: Beacon(clBeacon: beacon), in: BeaconRegion(clBeaconRegion: region))
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            syncFromTrackedRegions()
        }
    }
}
