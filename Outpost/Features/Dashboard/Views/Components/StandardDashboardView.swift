//
//  StandardDashboardView.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import SwiftUI
import SwiftData

struct StandardDashboardView: View {
    @Environment(\.modelContext) var context
    @Environment(SessionManager.self) var sessionManager
    
    
    let race: Race
    
    @Query(sort: \StatusEvent.timestamp, order: .reverse) var allEvents: [StatusEvent]
    var localEvents: [StatusEvent] {
        guard let currentCp = sessionManager.currentCheckpoint else { return [] }
        return allEvents.filter{$0.checkpointId == currentCp.id}
    }
    
    @State private var showScanner = false
    @State private var showManualEntry = false
    
    var body: some View {
        VStack(spacing:0){
            //MARK: header
            if let cp = sessionManager.currentCheckpoint {
                HStack{
                    Image(systemName: cp.type.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color(cp.type.color))
                        .clipShape(.circle)
                    
                    VStack(alignment: .leading){
                        Text("Current Station")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Text(cp.name)
                            .font(.title3)
                            .bold()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing){
                        Text("\(localEvents.count)")
                            .font(.title2)
                            .bold()
                        Text("Entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
            
            //MARK: Entry Area
            VStack(spacing:20){
                Spacer()
                
                //Scanner
                Button{
                    showScanner = true
                } label: {
                    VStack{
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 60))
                        Text("SCAN BIB")
                    }
                    .foregroundStyle(.white)
                    .frame(width: 180, height: 180)
                    .background(Circle().fill(Color.blue).shadow(radius: 10))
                }
                
                //Manual Entry
                Button("Manual Entry"){
                    showManualEntry = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            
            //MARK: Recent Activity
            VStack(alignment: .leading){
                Text("RECENT ACTIVITY")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top,10)
                List{
                    ForEach(localEvents.prefix(10)){ event in
                        HStack{
                            Text(event.timestamp.formatted(date: .omitted, time: .standard))
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if let runner = event.runner {
                                Text("#\(runner.bibNumber)")
                                    .font(.headline)
                            }else{
                                Text("Unknown")
                                    .foregroundStyle(.red)
                            }
                            
                            Image(systemName: event.type == .arrival ? "arrow.down.right" : "arrow.up.right")
                                .foregroundStyle(event.type == .arrival ? .green : .orange)
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
                .listStyle(.plain)
            }
            .frame(height: 250)
            .background(Color(UIColor.secondarySystemBackground))
            
        }
        .sheet(isPresented: $showScanner){
            QREntryView()
        }
        .sheet(isPresented: $showManualEntry){
            ManualEntryView()
        }
        
    }
    
    private func deleteEvent(at offsets: IndexSet) {
        for index in offsets {
            context.delete(localEvents[index])
        }
    }
}

#Preview {
    StandardDashboardView(race: Race(name: "Test Race", raceType: .standard, startDate: Date()))
        .environment(SessionManager())
}
