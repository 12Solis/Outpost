//
//  SyncManager.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation
import SwiftData
import MultipeerConnectivity
import Combine

@MainActor
class SyncManager: Observable, ObservableObject {
    private let service: MultipeerService
    private let context: ModelContext
    
    init(service: MultipeerService, context: ModelContext) {
        self.service = service
        self.context = context
        
        self.service.onDataReceived = { [weak self] data, peer in
            Task { @MainActor in
                self?.handleData(data, from: peer)
            }
        }
        
        self.service.onPeerConnected = { [weak self] peer in
            print("Peer \(peer.displayName) joined. Starting Backfill...")
            self?.syncHistory()
        }
    }
    
    //MARK: Send Data
    func broadcastEvent(_ event: StatusEvent){
        guard let runnerId = event.runner?.id else { return }
        
        let dto = StatusEventDTO(
            id: event.id,
            timeStamp: event.timestamp,
            type: event.type,
            checkpointId: event.checkpointId ?? UUID(),
            runnerId: runnerId
        )
        
        send(.statusEvent(dto))
    }
    
    func broadcastRunnerUpdate(_ runner: Runner){
        guard let raceId = runner.race?.id else { return }
        
        let dto = RunnerDTO(
            id: runner.id,
            bibNumber: runner.bibNumber,
            status: runner.currentStatus,
            raceId: raceId
        )
        
        send(.runnerUpdate(dto))
    }
    
    func broadcastRace(_ race: Race){
        
        let cpDTOs = race.checkpoints.map { cp in
            CheckpointDTO(
                id: cp.id,
                name: cp.name,
                sequenceOrder: cp.sequenceOrder,
                distanceFromStart: cp.distanceFromStart,
                type: cp.type
            )
        }
        
        let raceDTO = RaceDTO(
            id: race.id,
            name: race.name,
            type: race.raceType,
            startDate: race.startDate,
            warningPace: race.warningPace,
            criticalPace: race.criticalPace,
            checkpoints: cpDTOs
        )
        
        send(.raceDefinition(raceDTO))
    }
    
    private func send(_ packet: syncPacket){
        do{
            let data = try JSONEncoder().encode(packet)
            service.send(data: data)
        }catch {
            print("Failed to encode packet: \(error)")
        }
    }
    
    //MARK: History
    func syncHistory(){
        let descriptor = FetchDescriptor<StatusEvent>(sortBy: [SortDescriptor(\.timestamp)])
        
        guard let allEvents = try? context.fetch(descriptor) else {
            print("Backfill failed: Could not fetch events")
            return
        }
        
        print("Backfilling \(allEvents.count) events")
        
        let runnerDescriptor = FetchDescriptor<Runner>()
        if let allRunners = try? context.fetch(runnerDescriptor) {
            for runner in allRunners {
                broadcastRunnerUpdate(runner)
            }
        }
        
        for event in allEvents {
            broadcastEvent(event)
        }
        
        print("Backfill complete")
        
    }
    
    //MARK: Reciving Data
    private func handleData(_ data: Data, from peer: MCPeerID){
        do{
            let packet = try JSONDecoder().decode(syncPacket.self, from: data)
            
            switch packet {
            case.statusEvent(let dto):
                processIncomingEvent(dto)
            case.runnerUpdate(let dto):
                processIncomingRunner(dto)
            case.raceDefinition(let dto):
                processIncomingRace(dto)
            }
            
        } catch {
            print("Failed to decode packet from \(peer.displayName): \(error)")
        }
    }
    
    //MARK: SwiftData Logic
    private func processIncomingEvent(_ dto: StatusEventDTO){
        let eventId = dto.id
        
        let descriptor = FetchDescriptor<StatusEvent>(predicate: #Predicate{$0.id == eventId})
        
        //Check if event already exists
        if (try? context.fetch(descriptor).count) ?? 0 > 0 {
            return
        }
        
        let runnerId = dto.runnerId
        let runnerDescriptor = FetchDescriptor<Runner>(predicate: #Predicate{$0.id == runnerId})
        
        guard let runner = try? context.fetch(runnerDescriptor).first else {
            print("Runner not found")
            return
        }
        
        let newEvent = StatusEvent(
            timestamp: dto.timeStamp,
            type: dto.type,
            runner: runner,
            checkpointId: dto.checkpointId
        )
        newEvent.id = dto.id
        
        context.insert(newEvent)
        print("Synced event: \(runner.bibNumber) at \(dto.type.rawValue)")
        
    }
    
    private func processIncomingRunner(_ dto: RunnerDTO){
        let runnerId = dto.id
        
        let descriptor = FetchDescriptor<Runner>(predicate: #Predicate{$0.id == runnerId})
        
        if let existing = try? context.fetch(descriptor).first {
            existing.currentStatus = dto.status
        } else {
            let raceId = dto.raceId
            let raceDescriptor = FetchDescriptor<Race>(predicate: #Predicate { $0.id == raceId })
            
            if let race = try? context.fetch(raceDescriptor).first {
                let newRunner = Runner(bibNumber: dto.bibNumber, race: race)
                newRunner.id = dto.id
                newRunner.currentStatus = dto.status
                context.insert(newRunner)
            }
        }
    }
    
    private func processIncomingRace(_ dto: RaceDTO){
        //Check if already exists
        let raceId = dto.id
        let descriptor = FetchDescriptor<Race>(predicate: #Predicate{$0.id == raceId})
        
        if (try? context.fetch(descriptor).count) ?? 0 > 0 {
            print("Already have race: \(dto.name)")
            return
        }
        //Create
        let newRace = Race(
            name: dto.name,
            raceType: dto.type,
            startDate: dto.startDate,
            warningPace: dto.warningPace,
            criticalPace: dto.criticalPace
        )
        newRace.id = dto.id
        context.insert(newRace)
        
        //Create checkpoints
        for cpDTO in dto.checkpoints {
            let newCP = Checkpoint(
                name: cpDTO.name,
                sequenceOrder: cpDTO.sequenceOrder,
                distanceFromStart: cpDTO.distanceFromStart,
                type: cpDTO.type
            )
            newCP.id = cpDTO.id
            newCP.race = newRace
            context.insert(newCP)
        }
        
        print("Received Race: \(dto.name) with \(dto.checkpoints.count) CPs")
    }

    
}

