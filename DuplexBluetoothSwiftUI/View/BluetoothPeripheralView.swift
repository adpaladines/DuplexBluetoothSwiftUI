//
//  BluetoothPeripheralView.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import SwiftUI

struct BluetoothPeripheralView: View {
    @ObservedObject var viewModel = BluetoothPeripheralViewModel()
    
    var body: some View {
        VStack(spacing: 36) {
            Button {
                viewModel.configureService()
            } label: {
                Text("Configure data")
            }
            Button {
                viewModel.startPublishingData()
            } label: {
                Text("Start Sending data")
            }
            Button {
                viewModel.stopPublishingData()
            } label: {
                Text("Stop Sending data")
            }

            List(viewModel.peripherals, id: \.identifier) { peripheral in
                Text(peripheral.name ?? "Unknown")
            }
        }
        .navigationBarTitle("Discovered Peripherals")
    }
}

#Preview {
    BluetoothPeripheralView()
}
