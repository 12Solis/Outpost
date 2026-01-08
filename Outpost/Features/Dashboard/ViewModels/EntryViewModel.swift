//
//  ManualEntryViewModel.swift
//  Outpost
//
//  Created by Leonardo Solís on 04/01/26.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class EntryViewModel{
    
    var bibInput: String = ""
    var selectedMode: EventType = .arrival
    
    var lastActionMessage: String? = nil
    var isSuccess: Bool = false
    
    func append(_ number: String){
        if bibInput.count < 5 {
            bibInput.append(number)
        }
    }
    
    func deleteLast(){
        if !bibInput.isEmpty {
            bibInput.removeLast()
        }
    }
    
    func submit(context: ModelContext, session: SessionManager, syncManager: SyncManager?){
        guard !bibInput.isEmpty, let race = session.activeRace, let cp = session.currentCheckpoint else {
            print("Submission Failed: Missing data (Race: \(session.activeRace?.name ?? "Nil"), CP: \(session.currentCheckpoint?.name ?? "Nil"))")
            return
        }
        
        print("Submitting Bib: \(bibInput)...")
        
        let bib = bibInput
        
        //MARK: Find or Create runner
        let raceId = race.id
        let descriptor = FetchDescriptor<Runner> (
            predicate: #Predicate{$0.bibNumber == bib && $0.race?.id == raceId}
        )
        
        let runner: Runner
        if let existing = try? context.fetch(descriptor).first {
            print("   Found existing runner")
            runner = existing
        } else {
            print("   Creating new runner")
            runner = Runner(bibNumber: bib, race: race)
            context.insert(runner)
        }
        
        syncManager?.broadcastRunnerUpdate(runner)
        
        //MARK: Create Event
        
        let event = StatusEvent(type: selectedMode, runner: runner, checkpointId: cp.id)
        context.insert(event)
        

        do {
            try context.save()
            print("Event Saved Successfully!")
        } catch {
            print("CORE DATA SAVE ERROR: \(error)")
        }
        
        syncManager?.broadcastEvent(event)
        
        //MARK: Results and Reset
        lastActionMessage = "Bib #\(bib) \(selectedMode == .arrival ? "Arrived" : "Departed")"
        isSuccess = true
        bibInput = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.lastActionMessage != nil {
                self.lastActionMessage = nil
            }
        }
        
    }    
    
    
}
