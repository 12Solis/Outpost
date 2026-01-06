//
//  DashboardView.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(SessionManager.self) var sessionManager
    
    let race: Race
    
    var body: some View {
        Group{
            if race.raceType == .backyard {
                Text("")
            } else{
                StandardDashboardView(race: race)
            }
        }
        .navigationTitle(race.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal){
                VStack{
                    Text(race.name)
                        .font(.headline)
                    if let cp = sessionManager.currentCheckpoint {
                        Text(cp.name)
                            .font(.caption)
                            .foregroundStyle(Color(cp.type.color))
                    }
                }
            }
        }
        
        
    }
}

#Preview {
    DashboardView(race: Race(name: "Test Race", raceType: .standard, startDate: Date()))
        .environment(SessionManager())
}
