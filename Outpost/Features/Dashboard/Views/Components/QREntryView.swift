//
//  QREntryView.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import SwiftUI

struct QREntryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Environment(SessionManager.self) var sessionManager
    
    @State private var scannerViewModel = EntryViewModel()
    
    var body: some View {
        VStack(spacing:0) {
            
            HStack {
                Text("Point at Bib")
                    .font(.headline)
                Spacer()
                Button("Close") { dismiss() }
            }
            .padding()
            
            Picker("Mode", selection: $scannerViewModel.selectedMode) {
                Text("IN (Arrival)").tag(EventType.arrival)
                Text("OUT (Departure)").tag(EventType.departure)
            }
            .pickerStyle(.segmented)
            
            Text(scannerViewModel.selectedMode == .arrival ? "Scanning Arrivals" : "Scanning Departures")
                .font(.caption)
                .foregroundStyle(scannerViewModel.selectedMode == .arrival ? .green : .orange)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
            
            // Camera
        ZStack(alignment: .bottom) {
            CameraView { scannedCode in
                print("Scanned: \(scannedCode)")
                
                scannerViewModel.bibInput = scannedCode
                
                scannerViewModel.sumbit(context: context, session: sessionManager)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
            
            //Result message
            if let message = scannerViewModel.lastActionMessage {
                Text(message)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .background(scannerViewModel.isSuccess ? Color.green : Color.red)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
}

#Preview {
    QREntryView()
        .environment(SessionManager())
}
