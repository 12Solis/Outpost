//
//  Checkpoint.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//

import Foundation
import SwiftData

@Model
final class Checkpoint{
    @Attribute(.unique) var id: UUID
    var name: String
    var sequenceOrder: Int
    var distanceFromStart: Double
    var race: Race?
    var type: CheckpointType
    
    init(name: String, sequenceOrder: Int, distanceFromStart: Double, type: CheckpointType = .timingOnly){
        self.id = UUID()
        self.name = name
        self.sequenceOrder = sequenceOrder
        self.distanceFromStart = distanceFromStart
        self.type = type
    }
}

enum CheckpointType: String, Codable, CaseIterable, Identifiable {
    case start, finish, aidStation, waterOnly, timingOnly
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .start: "Start Line"
        case .finish: "Finish Line"
        case .aidStation: "Aid Station"
        case .waterOnly: "Hydration"
        case .timingOnly: "Timing Zone"
        }
    }
    
    var icon: String {
        switch self {
        case .start: "flag.fill"
        case .finish: "flag.checkered"
        case .aidStation: "cross.case.fill"
        case .waterOnly: "drop.fill"
        case .timingOnly: "stopwatch.fill"
        }
    }
    
    var color: String {
        switch self {
        case .start: "green"
        case .finish: "black"
        case .aidStation: "red"
        case .waterOnly: "blue"
        case .timingOnly: "gray"
        }
    }
}

