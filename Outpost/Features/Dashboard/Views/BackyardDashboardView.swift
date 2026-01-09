//
//  BackyardDashboardView.swift
//  Outpost
//
//  Created by Leonardo Solís on 09/01/26.
//

import SwiftUI
import SwiftData

struct BackyardDashboardView: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(\.modelContext) var context
    @State private var viewModel: BackyardViewModel
    let race: Race
    
    @Query var allRunners: [Runner]
    
    @State private var lastProcessedLap = 1
    
    @State private var showScanner = false
    @State private var showManualEntry = false
    @State private var showStartCountdown = false
    @State private var showEndRaceAlert = false
    
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    
    init(race: Race) {
        self.race = race
        let raceId = race.id
        _allRunners = Query(filter: #Predicate { $0.race?.id == raceId }, sort: \.bibNumber)
        self.viewModel = .init(race: race)
    }
    
    var activeRunners: [Runner] {
        allRunners.filter { $0.currentStatus == .active }
    }
    
    var dnfRunners: [Runner] {
        allRunners.filter { $0.currentStatus != .active }
    }
        
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let state = BackyardLogic.calculateState(race: race, now: timeline.date)
            
            ZStack{
                
                VStack(spacing: 0) {
                    // MARK: Header
                    VStack(spacing: 8) {
                        
                        switch state.status {
                        case .scheduled:
                            VStack {
                                Text("READY TO START?")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Button {
                                    showStartCountdown = true
                                } label: {
                                    Text("START COUNTDOWN")
                                        .font(.title2.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .clipShape(Capsule())
                                }
                                .padding(.top, 10)
                            }
                            .padding(.bottom, 20)
                            
                        case .active:
                            Text("YARD \(state.currentLap)")
                                .font(.headline)
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.top)
                            
                            Text(BackyardLogic.formatTime(state.timeRemaining))
                                .font(.system(size: 70, weight: .black, design: .monospaced))
                                .foregroundStyle(state.timeRemaining < 300 ? Color.red : Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 5)
                            
                            Text("NEXT BELL: \(state.nextBell.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.bottom)
                            
                        case .finished:
                            Text("RACE ENDED")
                                .font(.largeTitle.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.vertical, 20)
                            
                            Text("Final Yard: \(viewModel.countTotalLaps(allRunners: allRunners))")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.bottom)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        state.status == .active ? Color.slateBlue :
                            state.status == .finished ? Color.gray : Color.slateBlue.opacity(0.8)
                    )
                    
                    // MARK: Runners Grid
                    ScrollView {
                        HStack {
                            Label("\(activeRunners.count) Active", systemImage: "figure.run")
                                .foregroundStyle(.green)
                            Spacer()
                            Label("\(dnfRunners.count) DNF", systemImage: "xmark.circle")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .font(.caption.bold())
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                            ForEach(activeRunners) { runner in
                                RunnerStatusCard(
                                    bib: runner.bibNumber,
                                    laps: viewModel.countLaps(for: runner),
                                    status: .active
                                )
                            }
                            ForEach(dnfRunners, id: \.self) { runner in
                                RunnerStatusCard(
                                    bib: runner.bibNumber,
                                    laps: viewModel.countLaps(for: runner),
                                    status: .dnf
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Entrys
                    HStack(spacing: 16) {
                        Button {
                            showScanner = true
                        } label: {
                            Label("Scan Finishers", systemImage: "qrcode.viewfinder")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(race.status != .active)
                        .opacity(race.status == .active ? 1 : 0.5)
                        
                        Button {
                            showManualEntry = true
                        } label: {
                            Image(systemName: "keyboard")
                                .font(.title2)
                                .frame(width: 56, height: 56)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(race.status != .active)
                        .opacity(race.status == .active ? 1 : 0.5)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                
                //MARK: Countdown
                if showStartCountdown {
                    RaceCountdownView(
                        onComplete: {
                            viewModel.startRace(context: context)
                            showStartCountdown = false
                        },
                        onCancel: {
                            showStartCountdown = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
                
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Menu {
                        Button {
                            exportData()
                        } label: {
                            Label("Export Results (CSV)", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        if race.status == .active {
                            Button(role: .destructive) {
                                showEndRaceAlert = true
                            } label: {
                                Label("End Race", systemImage: "flag.checkered")
                            }
                        } else if race.status == .finished {
                            Button {
                                viewModel.resumeRace(context: context)
                            } label: {
                                Label("Resume Race", systemImage: "arrow.uturn.backward")
                            }
                        }
                    } label: {
                        if isExporting {
                            ProgressView()
                        } else {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
            }
            
            .sheet(isPresented: $showScanner) { QREntryView() }
            .sheet(isPresented: $showManualEntry) { ManualEntryView() }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                        .presentationDetents([.medium, .large])
                }
            }
            
            .alert("End the Race?", isPresented: $showEndRaceAlert){
                Button("Cancel", role: .cancel){}
                Button("End Race", role: .destructive) {
                    viewModel.endRace(context: context)
                }
            } message:{
                Text("This will stop the timer and mark the event as complete. You can export results after this.")
            }
            .onChange(of: state.currentLap) { oldValue, newLap in
                guard race.status == .active else { return }
                
                if newLap > oldValue {
                    viewModel.eliminateRunners(context: context, allRunners: allRunners, currentCheckpointId: sessionManager.currentCheckpoint?.id, newCurrentLap: newLap)
                }
            }
            
            .onAppear{
                self.sessionManager.activeRace = race
                self.sessionManager.currentCheckpoint = race.checkpoints.first
                lastProcessedLap = state.currentLap
            }
        }
        
        
    }
    
    
    private func exportData() {
        guard let race = sessionManager.activeRace else { return }
        
        isExporting = true
 
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            if let url = CSVExporter.generateBackyardCSV(for: race) {
                self.exportURL = url
                self.showShareSheet = true
            }
            
            self.isExporting = false
        }
    }
    
}

#Preview {
    BackyardDashboardView(race: Race(name: "Test", raceType: .backyard))
        .environment(SessionManager())
}
