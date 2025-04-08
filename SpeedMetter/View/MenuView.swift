//
//  MenuView.swift
//  SpeedMetter
//
//  Created by Sk Jasimuddin on 18/01/1947 Saka.
//

import Foundation
import SwiftUI
struct MenuView: View {
    @ObservedObject var monitor: NetworkMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Picker("Unit:", selection: $monitor.selectedUnit) {
//                ForEach(SpeedUnit.allCases, id: \.self) { unit in
//                    Text(unit.rawValue).tag(unit)
//                }
//            }
//            .pickerStyle(.inline)
//            
//            Divider()
            
            HStack{
                Text("NetSpeed Lite")
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
    }
}
