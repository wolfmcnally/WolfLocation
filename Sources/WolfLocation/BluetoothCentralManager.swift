//
//  BluetoothCentralManager.swift
//  WolfLocation
//
//  Created by Wolf McNally on 3/1/18.
//

import CoreBluetooth
import WolfKit

public class BluetoothCentralManager: NSObject, CBCentralManagerDelegate {
    private let queue: DispatchQueue?
    private let options: [String: Any]?

    private var cbCentralManager: CBCentralManager!
    public private(set) var isStarted: Bool = false

    public let onDidUpdateState = Event<CBManagerState>()

    public var state: CBManagerState {
        return cbCentralManager.state
    }

    public init(queue: DispatchQueue? = nil, options: [String: Any]? = nil) {
        self.queue = queue
        self.options = options
        super.init()
    }

    public func start() {
        guard cbCentralManager == nil else { return }
        cbCentralManager = CBCentralManager(delegate: self, queue: queue, options: options)
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onDidUpdateState.notify(state)
    }
}
