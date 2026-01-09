//
//  Race.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation
import SwiftData

@Model
final class Race {
    @Attribute(.unique) var id: UUID
    var name : String
    var raceType : RaceType
    var startDate : Date
    var warningPace: Double
    var criticalPace: Double
    var endTime: Date?
    var status: RaceStatus = RaceStatus.scheduled
    
    
    @Relationship(deleteRule: .cascade) var checkpoints : [Checkpoint] = []
    @Relationship(deleteRule: .cascade) var runners : [Runner] = []
    
    init(name:String, raceType: RaceType, startDate:Date=Date(), warningPace: Double = 15.0, criticalPace: Double = 20.0){
        self.id = UUID()
        self.name = name
        self.raceType = raceType
        self.startDate = startDate
        self.warningPace = warningPace
        self.criticalPace = criticalPace
        self.endTime = nil
        self.status = .scheduled
    }
}

enum RaceType: String, Codable, CaseIterable {
    case standard, backyard, stage
    var displayName: String {
        switch self {
        case .standard: "Standard Trail"
        case .backyard: "Backyard Ultra"
        case .stage: "Stage Race"
        }
    }
}

enum RaceStatus: String, Codable {
    case scheduled
    case active
    case finished
}
