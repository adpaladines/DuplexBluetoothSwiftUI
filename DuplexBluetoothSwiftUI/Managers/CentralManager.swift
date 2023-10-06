//
//  CentralManager.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import Foundation
import CoreBluetooth

//TODO: Call BluetoothService.plist file

protocol CentralManagerDelegate: AnyObject {
    func cmIsScanning(available: Bool)
    func cmDidDiscover(peripheral: CBPeripheral)
    func cmDidConnect(with peripheral: CBPeripheral, success: Bool)
    func cmDidGet(value: Data, from characteristic: CBCharacteristic)
}

extension CentralManagerDelegate {
    func cmDidFailConnect(with peripheral: CBPeripheral, error: Error?) {
        
    }
}

class CentralManager: NSObject {

    var heartRatePeripheral: CBPeripheral?
    
    weak var delegate: CentralManagerDelegate?
    var cbCentralManager: CBCentralManager!
    
    //TODO: dependency inversion: Send CBUUID values from outside to make this module reusable
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
//        cbCentralManager.scanForPeripherals(withServices: [CBUUIDs.uuidService], options: nil)
        cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
}

extension CentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            delegate?.cmIsScanning(available: true)
            print("Is Powered On.")
            return
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
        delegate?.cmIsScanning(available: false)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        delegate?.cmDidDiscover(peripheral: peripheral)
    }
    
    // You can define other methods and properties specific to your central functionality

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        self.delegate?.cmDidConnect(with: peripheral, success: true)
        print("Peripheral: \(peripheral.name ?? peripheral.identifier.uuidString) is connected")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUIDs.uuidService])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate?.cmDidFailConnect(with: peripheral, error: error)
    }
    
    
}


extension CentralManager: CBPeripheralDelegate {
    
    //After start discovering services, this method is triggered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("service:")
            print(service.uuid.uuidString)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //After `peripheral.discoverCharacteristics(nil, for: service)`, this method is triggered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else  { return }
        
        for characteristic in characteristics {
            print("characteristic:")
            print(characteristic.uuid.uuidString)
            //verifying in we can read data
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            //verifying in we can be notified on data changes
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
//            //verifying in we can write data
//            if characteristic.properties.contains(.write) {
//                peripheral.writeValue("hello".data(using: .utf8)!, for: CBDescriptor )
//            }
        }
        
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//
//    }
    
    //Every time a characteristic changes its value, this method will be called (for readable characteristics)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //characteristic.value is Data Type, we can cast it to an expected type.
        switch characteristic.uuid {
        case CBUUIDs.uuidCharacteristicOne:
            if let val = characteristic.value {
                delegate?.cmDidGet(value: val, from: characteristic)
            }
            
//            peripheral.writeValue("Hello World!".data(using: .utf8)!, for: characteristic, type: .withResponse)
            //didWriteValueFor characteristic will be called
            break
        case CBUUIDs.uuidCharacteristicTwo:
            if let val = characteristic.value {
                delegate?.cmDidGet(value: val, from: characteristic)
            }
//            peripheral.writeValue("Hello World 2!".data(using: .utf8)!, for: characteristic, type: .withResponse)
            break
        default:
            print("Unhandled characteristic UUID: \(characteristic.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("Signal for \(peripheral.identifier): \(RSSI)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error_ = error {
            print(error_.localizedDescription)
            return
        }
        print("In peripherial: \(peripheral.identifier.uuidString)")
        print("In Characteristic: \(characteristic.uuid.uuidString)")
        print("Writen: \(String(data: characteristic.value ?? Data(), encoding: .utf8) ?? "")")
    }
    
    
}
