//
//  BluetoothPeripheralViewModel.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheralViewModel: ObservableObject {
    @Published var peripherals: [CBPeripheral] = []
    @Published var centrals: [CBCentral] = []
    @Published var stringReceived: String = ""

    var peripheralManager: PeripheralManager?
    
    init() {}
    func configureService() {
        peripheralManager = PeripheralManager()
        peripheralManager?.delegate = self
    }
    
    func startPublishingData() {
        peripheralManager?.addService()
    }
    
    func stopPublishingData() {
        peripheralManager?.removeServices()
        peripheralManager?.delegate = nil
        peripheralManager = nil
    }

}

extension BluetoothPeripheralViewModel: PeripheralManagerDelegate {
    
    func didReceive(data: Data, for uuidCharacteristic: CBUUID) {
        guard let string = String(data: data, encoding: .utf8) else {
            print("Data decode failed.")
            return
        }
        stringReceived = string
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheralManager: PeripheralManager) {
        
    }
    
    
    
}
