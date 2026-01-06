//
//  RaceCreationViewModel.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class RaceCreationViewModel{
    
    var name: String = ""
    var selectedType: RaceType = .standard
    var startDate: Date = Date()
    var checkpoints: [tempCheckpoint] = []
    var warningPace: Double = 15.0
    var criticalPace: Double = 25.0
    
    struct tempCheckpoint: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var distance: Double
        var type: CheckpointType
        
    }
    
    func initializeCheckpoints(for type: RaceType) {
        checkpoints.removeAll()
        
        if type == .backyard {
            checkpoints.append(tempCheckpoint(name: "The Corral", distance: 0.0, type: .start))
        } else {
            checkpoints.append(tempCheckpoint(name: "Start Line", distance: 0.0, type: .start))
            checkpoints.append(tempCheckpoint(name: "Finish Line", distance: 50.0, type: .finish))
        }
    }
    
    func addCheckpoint(){
        let lastDist = checkpoints.last?.distance ?? 0
        
        if selectedType != .backyard, let finishIndex = checkpoints.firstIndex(where: { $0.type == .finish }) {
            let newCP = tempCheckpoint(name: "Aid Station", distance: lastDist - 5, type: .aidStation)
            checkpoints.insert(newCP, at: finishIndex)
            
        } else {
            checkpoints.append(tempCheckpoint(name: "Aid Station", distance: lastDist + 5, type: .aidStation))
        }
    }
    
    func removeCheckpoint(id: UUID){
        checkpoints.removeAll(where: { $0.id == id })
    }
    
    func moveCheckpoint(from source: IndexSet, to destination: Int){
        checkpoints.move(fromOffsets: source, toOffset: destination)
    }
    
    func save(context: ModelContext){
        let newRace = Race(
            name: name,
            raceType: selectedType,
            startDate: startDate,
            warningPace: warningPace,
            criticalPace: criticalPace
        )
        context.insert(newRace)
        
        for(index, tempCP) in checkpoints.enumerated(){
            let newCP = Checkpoint(name: tempCP.name,
                                   sequenceOrder: index,
                                   distanceFromStart: tempCP.distance,
                                   type: tempCP.type
            )
            newCP.race = newRace
            context.insert(newCP)
        }
        
        print("Saved Race: \(name) with \(checkpoints.count) CPs")
        
    }
    
    
}
