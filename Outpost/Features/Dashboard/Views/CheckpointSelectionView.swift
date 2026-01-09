//
//  CheckpointSelectionView.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import SwiftUI
import SwiftData
import TipKit

struct CheckpointSelectionView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(\.syncManager) var syncManager
    
    @State private var showLiveTracking = false
    @State private var navigateToDashboard = false
    
    let liveTrackViewTip = LiveTrackTip()
    let race: Race
    var sortedCheckpoints: [Checkpoint] {
        race.checkpoints.sorted { $0.sequenceOrder < $1.sequenceOrder }
    }
    
    @Query var allRunners: [Runner]
    var onTrailCount: Int {
        allRunners.filter { $0.isOnTrail && $0.race?.id == race.id }.count
    }
    
    var atStationCount: Int {
        allRunners.filter { !$0.isOnTrail && $0.currentStatus == .active && $0.race?.id == race.id }.count
    }
    
    var body: some View {
        VStack(spacing:0){
            
            //Button
            LiveTrackingButton(race: race, showLiveTracking: $showLiveTracking)

            //Tip
            TipView(liveTrackViewTip,arrowEdge: .top)
                .tipBackground(Color.slateBlue.opacity(0.2))

            //List of checkpoints
            List{
                Section{
                    ForEach(sortedCheckpoints){ cp in
                        
                        Button{
                            sessionManager.selectRace(race)
                            sessionManager.selectCheckpoint(cp)
                            
                            navigateToDashboard = true
                                
                        }label: {
                            HStack{
                                Image(systemName: cp.type.icon)
                                    .font(.title2)
                                    .foregroundStyle(Color(cp.type.color))
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading){
                                    Text(cp.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    HStack{
                                        Text("Km \(cp.distanceFromStart, format: .number.precision(.fractionLength(1)))")
                                        
                                        if cp.type == .start {
                                            Text("- Start")
                                        } else if cp.type == .finish {
                                            Text("- Finish")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical,4)
                        }
                        
                    }
                    
                } header: {
                    Text("Select your Location")
                } footer:{
                    Text("Select the checkpoint where youre currently at. This determines how splits are calculated.")
                }
                
            }
        }
        .navigationTitle(race.name)
        .onAppear {
            if sessionManager.activeRace == nil {
                sessionManager.selectRace(race)
            }
        }
        
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                ConnectionStatusView(session: sessionManager, activeRace: race)
            }
        }
        .sheet(isPresented: $showLiveTracking){
            LiveTrackingView()
        }
        .navigationDestination(isPresented: $navigateToDashboard){
            StandardDashboardView(sessionManager: sessionManager,race: race)
        }
        
        
    }
}

#Preview {
    CheckpointSelectionView(race: Race(name: "Test", raceType: .backyard, startDate: Date()))
        .environment(SessionManager())
        .environment(MultipeerService())
}
