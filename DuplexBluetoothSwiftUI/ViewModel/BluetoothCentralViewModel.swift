//
//  BluetoothViewModel.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import Foundation
import CoreBluetooth

class BluetoothViewModel: ObservableObject {
    @Published var isAvailable: Bool = false
    @Published var peripherals: [CBPeripheral] = []
    @Published var heartRatePeripheral: CBPeripheral?
    @Published var peripheralNames: [String] = []
    @Published var stringReceived: String = ""

    var centralManager: CentralManager!
    var peripheralManager: PeripheralManager!

    init() { }
    
    func configureScanning() {
        centralManager = centralManager ?? CentralManager()
        centralManager.delegate = self
    }
    
    func startScanning() {
        centralManager.startScanning()
    }
    
    func stopScanning() {
        centralManager.delegate = nil
        centralManager = nil
    }
}

extension BluetoothViewModel: CentralManagerDelegate {
    
    func cmIsScanning(available: Bool) {
        isAvailable = available
    }
    
    func cmDidDiscover(peripheral: CBPeripheral) {
        guard peripheral.name != nil else { return }
        print(peripheral.name as Any)
        print(peripheral.identifier)
        print(peripheral.services?.count as Any)
        print(peripheral.services?.description as Any)
        if let serv = peripheral.services {
            print(serv.compactMap { $0.uuid})
        }
        
        //MARK: - This part identifies and stores the service we want to connect.
//        if peripheral.identifier.uuidString == CBUUIDs.uuidService.uuidString {
        if peripheral.identifier.uuidString == "4C1D98B0-37FB-6B4A-D773-039940B96D42" {
            self.centralManager.cbCentralManager.stopScan()
            self.centralManager.cbCentralManager.connect(peripheral)
        }
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "Error: No name.")
        }
    }
    
    func cmDidConnect(with peripheral: CBPeripheral, success: Bool) {
        print("Peripheral: \(peripheral.name ?? peripheral.identifier.uuidString) is \(success ? "connected": "Not connected").")
        heartRatePeripheral?.discoverServices([CBUUIDs.uuidService])
    }
    
    func cmDidGet(value: Data, from characteristic: CBCharacteristic) {
        guard let newVal = String(data: value, encoding: .utf8) else {
            print("NOT LEGIBLE DATA!")
            return
        }
        stringReceived = newVal
    }
    
}

//extension BluetoothViewModel: PeripheralManagerDelegate {
//    
//    func didReceive(data: Data, for uuidCharacteristic: CBUUID) {
//        guard let string = String(data: data, encoding: .utf8) else {
//            print("Data decode failed.")
//            return
//        }
//        stringReceived = string
//    }
//    
//    
//    func peripheralManagerDidUpdateState(_ peripheralManager: PeripheralManager) {
//        // Handle peripheral manager state updates
//        if peripheralManager.cbPeripheralManager.state == .poweredOn {
//            centralManager.startScanning()
//        }
//    }
//}
