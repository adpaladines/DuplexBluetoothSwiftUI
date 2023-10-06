//
//  BluetoothCentralView.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/6/23.
//

import SwiftUI

struct BluetoothCentralView: View {
    @ObservedObject var viewModel = BluetoothViewModel()
    
    var body: some View {
        VStack(spacing: 36) {
            Text(viewModel.stringReceived)
            Button {
                viewModel.configureScanning()
            } label: {
                Text("Configure Scanner")
            }
            Button {
                viewModel.startScanning()
            } label: {
                Text("Start Scanning")
            }
            Button {
                viewModel.stopScanning()
            } label: {
                Text("Stop Scanning")
            }
            List(viewModel.peripherals, id: \.identifier) { peripheral in
                VStack {
                    Text(peripheral.name ?? "Unknown")
                    if let servs = peripheral.services {
                        let asd = servs.compactMap { $0.uuid.uuidString }//.joined(separator: ";")
                        Text(asd.joined(separator: ";\n"))
                            .background(Color.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Discovered Devices")
    }
}

#Preview {
    BluetoothCentralView()
}
