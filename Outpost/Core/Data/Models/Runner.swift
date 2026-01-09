//
//  Runner.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Runner: Identifiable {
    @Attribute(.unique) var id : UUID
    var bibNumber: String
    var name: String?
    var race: Race?
    var currentStatus: RunnerStatus

    @Relationship(deleteRule: .cascade) var history: [StatusEvent] = []
    
    init(bibNumber:String, name:String? = nil, race:Race? = nil){
        self.id = UUID()
        self.bibNumber = bibNumber
        self.name = name
        self.race = race
        self.currentStatus = .active

    }
    
}

enum RunnerStatus: String, Codable {
    case active
    case dnf
    case finished
    case onLoop
    case recovering
}


extension Runner {
    
    
    // MARK: Logic
    var lastEvent: StatusEvent? {
        history.sorted { $0.timestamp > $1.timestamp }.first
    }
    
    var lastKnownCheckpoint: Checkpoint? {
        guard let event = lastEvent else { return nil }
        return race?.checkpoints.first(where: { $0.id == event.checkpointId })
    }
    
    var lastKnownLocationName: String {
        guard let event = lastEvent else { return "Not Started" }
        
        if let cp = race?.checkpoints.first(where: { $0.id == event.checkpointId }) {
            return cp.name
        }
        return "Unknown"
    }
    
    var nextExpectedCheckpoint: Checkpoint? {
        guard let currentCP = lastKnownCheckpoint,
              let allCPs = race?.checkpoints.sorted(by: { $0.sequenceOrder < $1.sequenceOrder })
        else { return nil }
        
        if let idx = allCPs.firstIndex(where: { $0.id == currentCP.id }), idx + 1 < allCPs.count {
            return allCPs[idx + 1]
        }
        return nil
    }
    
    var isOnTrail: Bool {
        guard let last = lastEvent else { return false }
        return last.type == .departure
    }
    
    var lastMovementTime: Date? {
        lastEvent?.timestamp
    }
    
    // MARK: Analysis
    var currentSegmentDistance: Double {
        guard let start = lastKnownCheckpoint,
              let end = nextExpectedCheckpoint
        else { return 0 }
        
        let dist = end.distanceFromStart - start.distanceFromStart
        return max(dist, 0.1)
    }
    
    var currentPaceValue: Double {
        guard isOnTrail, let lastTime = lastMovementTime else { return 0 }
        
        let timeElapsedMinutes = Date().timeIntervalSince(lastTime) / 60
        let pace = timeElapsedMinutes / currentSegmentDistance
        return pace
    }
    
    // MARK: Alert System
    enum AlertLevel {
        case normal
        case warning
        case critical
    }
    
    var alertStatus: AlertLevel {
        guard isOnTrail else { return .normal }
        
        let warningThreshold = race?.warningPace ?? 15.0
        let criticalThreshold = race?.criticalPace ?? 25.0
        
        if currentPaceValue > criticalThreshold {
            return .critical
        } else if currentPaceValue > warningThreshold {
            return .warning
        }
        
        return .normal
    }
    
    // MARK: Color
    var statusColor: Color {
        if currentStatus == .dnf { return .red }
        if currentStatus == .finished { return .gray }
        
        if isOnTrail {
            switch alertStatus {
            case .critical: return .red
            case .warning: return .orange
            case .normal: return .blue
            }
        } else {
            return .green
        }
    }
    
}
