//
//  BluetoothPeripheralManager.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreBluetooth
import CoreLocation
import WolfConcurrency
import WolfLog
import WolfFoundation

public class BluetoothPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    private let queue: DispatchQueue?
    private let options: [String: Any]?

    private var cbPeripheralManager: CBPeripheralManager!

    public let stateDidChange = Event<CBManagerState>()
    public var state: CBManagerState {
        return cbPeripheralManager.state
    }

    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        self.queue = queue
        self.options = options
        super.init()
    }

    deinit {
        guard isAdvertising else { return }
        stopAdvertising()
    }

    public func start() {
        guard cbPeripheralManager == nil else { return }
        cbPeripheralManager = CBPeripheralManager(delegate: self, queue: queue, options: options)
    }

    public func startAdvertising(_ advertisementData: [String: Any]? = nil) {
        assert(cbPeripheralManager.state == .poweredOn)
        cbPeripheralManager.startAdvertising(advertisementData)
    }

    public func stopAdvertising() {
        logTrace("🔥 \(cbPeripheralManager†) stopAdvertising")
        cbPeripheralManager.stopAdvertising()
    }

    public var isAdvertising: Bool {
        return cbPeripheralManager.isAdvertising
    }

    public func startAdvertising(beaconRegion: BeaconRegion, measuredPower: Int? = nil) {
        let clBeaconRegion = CLBeaconRegion(beaconRegion: beaconRegion)
        let peripheralData = clBeaconRegion.peripheralData(withMeasuredPower: measuredPower as NSNumber?)
        startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        stateDidChange.notify(state)
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        logTrace("🔥 \(peripheral) didStartAdvertising")
    }
}

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            fatalError()
        }
    }
}
