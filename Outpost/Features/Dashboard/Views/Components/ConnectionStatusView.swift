//
//  ConnectionStatusView.swift
//  Outpost
//
//  Created by Leonardo Solís on 06/01/26.
//

import SwiftUI
import MultipeerConnectivity

struct ConnectionStatusView: View {
    @Environment(MultipeerService.self) var service
    
    var session: SessionManager
    var activeRace: Race?
    
    var peerCount: Int {
        service.connectedPeers.count
    }
    var color: Color {
        peerCount == 0 ? .gray : .green
    }
    
    var body: some View {
        Menu {
            if peerCount == 0 {
                Text("Searching for devices...")
            } else {
                Text("Connected Devices:")
                ForEach(service.connectedPeers, id: \.self) { peer in
                    Label(peer.displayName, systemImage: "iphone")
                }
            }
            
            if let race = session.activeRace, let sync = session.syncManager {
                Divider()
                Button {
                    sync.broadcastRace(race)
                } label: {
                    Label("Share Current Race", systemImage: "square.and.arrow.up")
                }
                
            }else {
                //Debug
                Text(activeRace == nil ? "No Active Race" : "No Sync Manager")
                    .font(.caption).foregroundStyle(.secondary)
            }
            
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .shadow(color: color.opacity(0.5), radius: 4)
                
                Text(peerCount == 0 ? "Offline" : "\(peerCount) Peers")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ConnectionStatusView( session: SessionManager())
        .environment(MultipeerService())
}
