//
//  VirtualBeacon.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreLocation
import CoreBluetooth
import WolfCore

public class VirtualBeacon: Invalidatable {
    public let region: BeaconRegion

    private var stateChangeObserver: Event<CBManagerState>.Observer!
    private var peripheralManager: BluetoothPeripheralManager!

    public let stateDidChange = Event<CBManagerState>()
    public var state: CBManagerState {
        return peripheralManager.state
    }

    public init(region: BeaconRegion) {
        self.region = region
    }

    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    public func invalidate() {
        stopAdvertising()
    }

    public func start() {
        guard peripheralManager == nil else { return }

        peripheralManager = BluetoothPeripheralManager()
        stateChangeObserver ◊= peripheralManager.stateDidChange.add { [unowned self] state in
            if state == .poweredOn {
                self.peripheralManager.startAdvertising(beaconRegion: self.region)
            }
            self.stateDidChange.notify(state)
        }
        peripheralManager.start()
    }
}
