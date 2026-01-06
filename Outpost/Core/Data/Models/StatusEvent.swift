//
//  StatusEvent.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//

import Foundation
import SwiftData

@Model
final class StatusEvent{
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: EventType
    var runner: Runner?
    var checkpointId: UUID?
    
    init(timestamp: Date = Date(), type: EventType, runner: Runner, checkpointId: UUID){
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.runner = runner
        self.checkpointId = checkpointId
    }
}

enum EventType: String, Codable {
    case arrival
    case departure
    case scan
}
