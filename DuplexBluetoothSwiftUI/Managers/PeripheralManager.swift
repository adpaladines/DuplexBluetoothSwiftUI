//
//  PeripheralManager.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import Foundation
import CoreBluetooth

protocol PeripheralManagerDelegate: AnyObject {
    func peripheralManagerDidUpdateState(_ peripheralManager: PeripheralManager)
    func didReceive(data: Data, for uuidCharacteristic: CBUUID)
}

class PeripheralManager: NSObject {
    weak var delegate: PeripheralManagerDelegate?
    var cbPeripheralManager: CBPeripheralManager!

    
    var serviceOne: CBMutableService?
    var characteristicOne: CBMutableCharacteristic?
    
    override init() {
        super.init()
        let option = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
        cbPeripheralManager = CBPeripheralManager(delegate: self, queue: .main, options: option)
        let serviceUUID = CBUUIDs.uuidService
        serviceOne = CBMutableService(type: serviceUUID, primary: true)
        
        let characteristicUUID = CBUUIDs.uuidCharacteristicOne
        characteristicOne = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.read, .write],
            value: nil,
            permissions: [.readable, .writeable]
        )
    }
    
    public func startAdvertising(serviceID: String, name: String) {
        
        let valueData = name.data(using: .utf8)
        
        let serviceID = CBUUID(string: serviceID)
        let peripheralName = name
        
        let CustomChar = CBMutableCharacteristic(type: CBUUIDs.uuidCharacteristicOne, properties: [.read], value: valueData, permissions: [.readable])
        
        let myService = CBMutableService(type: serviceID, primary: true)
        myService.characteristics = [CustomChar]
        
        cbPeripheralManager.add(myService)
        
        if self.cbPeripheralManager.isAdvertising {
            self.cbPeripheralManager.stopAdvertising()
        }
        cbPeripheralManager.startAdvertising(
            [
                CBAdvertisementDataServiceUUIDsKey: [serviceID],
                CBAdvertisementDataOverflowServiceUUIDsKey:[serviceID],
                CBAdvertisementDataLocalNameKey: peripheralName
            ]
        )
    }
    
    func addService() {
        guard let charOne = characteristicOne, let serOne = serviceOne else {
            return
        }
        if self.cbPeripheralManager.isAdvertising {
            self.cbPeripheralManager.stopAdvertising()
        }
        serviceOne?.characteristics = [charOne]
        cbPeripheralManager?.add(serOne)
    }

    func startAdvertising(uuidService: CBUUID) {
        let advertisementData: [String : Any] = [
            CBAdvertisementDataServiceUUIDsKey: [uuidService],
//            CBAdvertisementDataOverflowServiceUUIDsKey:[serviceOne!.uuid],
            CBAdvertisementDataLocalNameKey: "New Peripheral",
        ]
        cbPeripheralManager?.startAdvertising(advertisementData)
        print("Advertising: \(uuidService.uuidString)")
    }
    
    func removeServices() {
        cbPeripheralManager.removeAllServices()
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    
    //MARK: - Configuration methods
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        delegate?.peripheralManagerDidUpdateState(self)
        
        if peripheral.state == .poweredOn {
            // Bluetooth is powered on, start advertising services
            print("YOU CAN ADD THE SERVICE!")
        } else {
            // Handle other Bluetooth states (e.g., powered off, unauthorized, etc.)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error_ = error {
            print(error_.localizedDescription as Any)
            return
        }
        startAdvertising(uuidService: service.uuid)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error_ = error {
            print(error_.localizedDescription as Any)
            return
        }
        print("Advertising:")
        print(peripheral.isAdvertising)
    }
    
    //MARK: - Observer methods

    //MARK: Read data triggered when received read request from Central
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        switch request.characteristic.uuid {
        case CBUUIDs.uuidCharacteristicOne:
            if request.offset > characteristicOne?.value?.count ?? 0 {
                request.value = "(1st) - First characteristic!".data(using: .utf8)
                cbPeripheralManager?.respond(to: request, withResult: .success)
            }else {
                request.value = "(No offset) - First characteristic!".data(using: .utf8)
                cbPeripheralManager?.respond(to: request, withResult: .success)
            }
            return
        case CBUUIDs.uuidCharacteristicTwo:
            request.value = "(2nd) - Second characteristic!".data(using: .utf8)
            cbPeripheralManager?.respond(to: request, withResult: .success)
            return
        default:
            let range = Range.init(
                uncheckedBounds: (
                    lower: request.offset,
                    upper: ((characteristicOne?.value?.count ?? 0) - request.offset)
                )
            )
            request.value = characteristicOne?.value?.subdata(in: range)
//            cbPeripheralManager?.respond(to: request, withResult: .attributeNotFound)
            cbPeripheralManager?.respond(to: request, withResult: .success)
        }
    }
    
    //MARK: Write data triggered when received writing request from Central
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            switch request.characteristic.uuid {
            case CBUUIDs.uuidCharacteristicOne, CBUUIDs.uuidCharacteristicTwo:
                guard let data = request.value else {
                    cbPeripheralManager.respond(to: request, withResult: .invalidAttributeValueLength)
                    return
                }
                delegate?.didReceive(data: data, for: request.characteristic.uuid)
                characteristicOne?.value = data
                cbPeripheralManager.respond(to: request, withResult: .success)
                return
            default:
                let range = Range.init(
                    uncheckedBounds: (
                        lower: request.offset,
                        upper: ((characteristicOne?.value?.count ?? 0) - request.offset)
                    )
                )
                request.value = characteristicOne?.value?.subdata(in: range)
    //            cbPeripheralManager?.respond(to: request, withResult: .attributeNotFound)
                cbPeripheralManager?.respond(to: request, withResult: .success)
            }
        }
    }
    
    //MARK: Sending updated chartacteristic value to subscribed channels
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case CBUUIDs.uuidCharacteristicOne, CBUUIDs.uuidCharacteristicTwo:
            if
                let stringData = Data(base64Encoded: "BLE tutorial 1"),
                let char = characteristic as? CBMutableCharacteristic {
                
                cbPeripheralManager.updateValue(stringData, for: char, onSubscribedCentrals: [central])
            }
            
            return
        default:
            
            return
        }
    }
    
}
