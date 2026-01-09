//
//  BackyardViewModel.swift
//  Outpost
//
//  Created by Leonardo Solís on 09/01/26.
//

import Foundation
import SwiftData
import SwiftUI

class BackyardViewModel {
    
    let race: Race
    
    init(race: Race) {
        self.race = race
    }
    
    func eliminateRunners(context: ModelContext, allRunners: [Runner], currentCheckpointId: UUID? , newCurrentLap: Int) {
        
        let requiredLaps = newCurrentLap - 1
        
        let activeRunners = allRunners.filter { $0.currentStatus == .active }
        
        for runner in activeRunners {
            let laps = countLaps(for: runner)

            if laps < requiredLaps {
                print("Runner \(runner.bibNumber) eliminated (Laps: \(laps), Required: \(requiredLaps))")
                runner.currentStatus = .dnf
                
                let dnfEvent = StatusEvent(type: .dnf, runner: runner, checkpointId: currentCheckpointId ?? UUID())
                 context.insert(dnfEvent)
            }
        }
        
        try? context.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func countLaps(for runner: Runner) -> Int {
        runner.history.filter { $0.type == .arrival }.count
    }

    func countTotalLaps(allRunners: [Runner]) -> Int {
        guard let lastRunner = allRunners.filter({ $0.currentStatus == .active }).first else { return 0 }
        return countLaps(for: lastRunner)
    }
    
    func startRace(context: ModelContext){
        print("Race started")
        race.startDate = Date.now
        race.status = .active
        try? context.save()
    }
    
    func endRace(context: ModelContext) {
        race.endTime = Date.now
        race.status = .finished
        try? context.save()
    }
    
    func resumeRace(context: ModelContext) {
        race.endTime = nil
        race.status = .active
        try? context.save()
    }
}
