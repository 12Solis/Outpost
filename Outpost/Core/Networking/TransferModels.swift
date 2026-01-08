//
//  TransferModels.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation

enum syncPacket: Codable{
    case statusEvent(StatusEventDTO)
    case runnerUpdate(RunnerDTO)
    case raceDefinition(RaceDTO)
}

struct RaceDTO: Codable {
    let id: UUID
    let name: String
    let type: RaceType
    let startDate: Date
    let warningPace: Double
    let criticalPace: Double
    let checkpoints: [CheckpointDTO]
}

struct CheckpointDTO: Codable {
    let id: UUID
    let name: String
    let sequenceOrder: Int
    let distanceFromStart: Double
    let type: CheckpointType
}

struct StatusEventDTO: Codable {
    let id: UUID
    let timeStamp: Date
    let type: EventType
    let checkpointId: UUID
    let runnerId: UUID
}

struct RunnerDTO: Codable {
    let id: UUID
    let bibNumber: String
    let status: RunnerStatus
    let raceId: UUID
}
