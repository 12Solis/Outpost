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
    
    func sumbit(context: ModelContext, session: SessionManager){
        guard !bibInput.isEmpty, let race = session.activeRace, let cp = session.currentCheckpoint else { return }
        
        let bib = bibInput
        
        //MARK: Find or Create runner
        let raceId = race.id
        let descriptor = FetchDescriptor<Runner> (
            predicate: #Predicate{$0.bibNumber == bib && $0.race?.id == raceId}
        )
        
        let runner: Runner
        if let existing = try? context.fetch(descriptor).first {
            runner = existing
        } else {
            runner = Runner(bibNumber: bib, race: race)
            context.insert(runner)
        }
        
        //MARK: Create Event
        let event = StatusEvent(type: selectedMode, runner: runner, checkpointId: cp.id)
        context.insert(event)
        
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
