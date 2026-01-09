//
//  LiveTrackingView.swift
//  Outpost
//
//  Created by Leonardo Solís on 05/01/26.
//

import SwiftUI
import SwiftData
import TipKit

struct LiveTrackingView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \Runner.bibNumber, order: .forward) var allRunners: [Runner]
    
    @State private var searchText = ""
    @State private var filter: TrackingFilter = .all
    
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    
    enum TrackingFilter: String, CaseIterable {
        case all = "All"
        case onTrail = "On Trail"
        case atStation = "At Station"
        case dnf = "DNF"
    }
    
    var filteredRunners: [Runner] {
        let raceRunners = allRunners.filter { $0.race?.id == sessionManager.activeRace?.id }
        
        let statusFiltered: [Runner]
        switch filter {
        case .all: statusFiltered = raceRunners
        case .onTrail: statusFiltered = raceRunners.filter { $0.isOnTrail && $0.currentStatus == .active }
        case .atStation: statusFiltered = raceRunners.filter { !$0.isOnTrail && $0.currentStatus == .active }
        case .dnf: statusFiltered = raceRunners.filter { $0.currentStatus == .dnf }
        }
        
        if searchText.isEmpty { return statusFiltered }
        return statusFiltered.filter { $0.bibNumber.contains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter
                Picker("Filter", selection: $filter) {
                    ForEach(TrackingFilter.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                List {
                    ForEach(filteredRunners) { runner in
                        RunnerRow(runner: runner)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search Bib #")
            }
            .navigationTitle("Live Tracking")
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading){
                    HStack{
                        Button("Close") { dismiss() }
                        
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportData()
                    } label: {
                        if isExporting {
                            ProgressView()
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .disabled(isExporting)
                }
                
            }
            
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                        .presentationDetents([.medium, .large])
                }
            }
            
        }
        
        
        .onAppear{
            Task{await  LiveTrackTip.liveTrackViewVisitedEvent.donate()}
        }
        
        
    }
    
    private func exportData() {
        guard let race = sessionManager.activeRace else { return }
        
        isExporting = true
 
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            if let url = CSVExporter.generateCSV(for: race) {
                self.exportURL = url
                self.showShareSheet = true
            }
            
            self.isExporting = false
        }
    }
}





struct RunnerRow: View {
    let runner: Runner
    
    var body: some View {
        HStack(alignment: .center) {
            
            statusBadge
            
            VStack(alignment: .leading, spacing: 4) {
            
                HStack {
                    Text("#\(runner.bibNumber)")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.bold)
                    
                    if runner.isOnTrail {
                        if let next = runner.nextExpectedCheckpoint {
                            Text("→ \(next.name)")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("@ \(runner.lastKnownLocationName)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                
                if runner.isOnTrail, let startTime = runner.lastMovementTime {
                    HStack(spacing: 4) {
                        Image(systemName: "stopwatch")
                            .font(.caption2)
                        
                        
                        Text(startTime, style: .timer)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.semibold)
                        

                        if runner.currentSegmentDistance > 0 {
                            
                            TimelineView(.periodic(from: .now, by: 10.0)) { context in
                                let pace = runner.currentPaceValue
                                
                                Text("(\(pace, format: .number.precision(.fractionLength(1))) min/km)")
                                    .font(.caption)
                                
                                    .foregroundStyle(paceColor(for: pace))
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                } else {
                    
                    Text("Resting since \(runner.lastEvent?.timestamp.formatted(date: .omitted, time: .shortened) ?? "-")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if runner.isOnTrail {
                VStack(alignment: .trailing) {
                    Text("\(runner.currentSegmentDistance, format: .number.precision(.fractionLength(1))) km")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("segment")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if runner.currentStatus == .dnf {
                Text("DNF")
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(6)
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.vertical, 6)
    }
    
    func paceColor(for pace: Double) -> Color {
        let warning = runner.race?.warningPace ?? 15.0
        let critical = runner.race?.criticalPace ?? 25.0
        
        if pace > critical { return .red }
        if pace > warning { return .orange }
        return .secondary
    }
    
    var statusBadge: some View {
        ZStack {
            if runner.alertStatus == .critical {
                
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            } else if runner.alertStatus == .warning {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark")
                    .foregroundStyle(.orange)
            } else if !runner.isOnTrail {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "house.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "figure.run")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
        }
        .frame(width: 50)
    }
}

#Preview {
    LiveTrackingView()
        .environment(SessionManager())
}
