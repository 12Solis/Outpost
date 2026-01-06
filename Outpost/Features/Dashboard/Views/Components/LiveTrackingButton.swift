//
//  LiveTrackingButton.swift
//  Outpost
//
//  Created by Leonardo Solís on 06/01/26.
//

import SwiftUI
import SwiftData

struct LiveTrackingButton: View {
    let race: Race
    
    
    @Query var allRunners: [Runner]
    var onTrailCount: Int {
        allRunners.filter { $0.isOnTrail && $0.race?.id == race.id }.count
    }
    
    var atStationCount: Int {
        allRunners.filter { !$0.isOnTrail && $0.currentStatus == .active && $0.race?.id == race.id }.count
    }
    
    @Binding var showLiveTracking: Bool
    
    var body: some View {
        Button {
            showLiveTracking = true
        } label: {
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "figure.run")
                    Text("\(onTrailCount)")
                        .font(.title2).fontWeight(.bold)
                    Text("On Trail")
                        .font(.caption).fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
    
                Divider().frame(height: 30)

                HStack {
                    Image(systemName: "house.fill")
                    Text("\(atStationCount)")
                        .font(.title2).fontWeight(.bold)
                    Text("Resting")
                        .font(.caption).fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.orange)
            }
            .padding(.vertical, 16)
            .overlay(alignment: .trailing) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray.opacity(0.5))
                    .padding(.trailing)
            }
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }
}
