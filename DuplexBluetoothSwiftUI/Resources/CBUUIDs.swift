//
//  CBUUIDs.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/5/23.
//

import CoreBluetooth

struct CBUUIDs {
    
    static let uuidService = CBUUID(
        string: "5DAA8B54-25E6-47C6-A1F5-30A0DA6F9200"
    )
    
    static let uuidServiceSecondary = CBUUID(
        string: "8862646E-5E17-4194-8EF2-AD722930D575"
    )
    
    static let uuidCharacteristicOne = CBUUID(
        string: "BBF2F19E-8900-4A25-8B40-7274B378A78A"
    )
    
    static let uuidCharacteristicTwo = CBUUID(
        string: "9F14E1E1-D5D1-4A20-B09A-07C8898485A2"
    )
}
