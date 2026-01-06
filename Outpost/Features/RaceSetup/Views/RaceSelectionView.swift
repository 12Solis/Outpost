//
//  RaceSelectionView.swift
//  Outpost
//
//  Created by Leonardo Solís on 29/12/25.
//

import SwiftUI
import SwiftData

struct RaceSelectionView: View {
    @Environment(\.modelContext) var context
    
    @Query(sort: \Race.startDate, order: .reverse) var races: [Race]
    
    @State private var showSetup = false
    
    var body: some View {
        NavigationStack{
            List{
                if races.isEmpty {
                    ContentUnavailableView(
                        "No events found",
                        systemImage:"flag.checkered",
                        description: Text("Create a race to start tracking")
                    )
                }else{
                    ForEach(races, id: \.self) { race in
                        
                        NavigationLink{
                           CheckpointSelectionView(race: race)
                        }label:{
                            VStack(alignment: .leading) {
                                Text(race.name).font(.headline)
                                HStack {
                                    Text(race.raceType.displayName)
                                    Text("•")
                                    Text("\(race.checkpoints.count) CPs")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteRace)
                }
            }
            .navigationTitle("Outpost")
            .toolbar{
                Button{
                    showSetup = true
                }label:{
                    Image(systemName:"plus")
                }
            }
            .sheet(isPresented: $showSetup){
                RaceSetupMainView()
            }
            
        }
        
        
    }
    private func deleteRace(at offsets: IndexSet) {
        for index in offsets {
            context.delete(races[index])
        }
    }
}

#Preview {
    RaceSelectionView()
}
