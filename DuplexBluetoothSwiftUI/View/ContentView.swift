//
//  ContentView.swift
//  DuplexBluetoothSwiftUI
//
//  Created by andres paladines on 10/4/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack(spacing: 64) {
                NavigationLink {
                    BluetoothCentralView()
                }label: {
                    Text("Open as Central")
                }
                
                NavigationLink {
                    BluetoothPeripheralView()
                }label: {
                    Text("Open as Peripheral")
                }
            }
            
        }
        .navigationBarTitle("Discovered Devices")
    }
}

#Preview {
    ContentView()
}
