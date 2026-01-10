//
//  BackyardLogic.swift
//  Outpost
//
//  Created by Leonardo Solís on 08/01/26.
//

import Foundation

struct BackyardLogic {
    
    struct State {
        var currentLap: Int
        var timeRemaining: TimeInterval
        var nextBell: Date
        var status: RaceStatus
    }
    
    static func calculateState(race: Race, now: Date = Date()) -> State {
        
        if race.status == .scheduled {
            return State(currentLap: 1, timeRemaining: 0, nextBell: race.startDate, status: .scheduled)
        }
        
        if race.status == .finished {
            return State(currentLap: 0, timeRemaining: 0, nextBell: race.endTime ?? .now, status: .finished)
        }
        
        let elapsed = now.timeIntervalSince(race.startDate)
        let hourInSeconds: Double = 3600
        
        let completedHours = Int(elapsed / hourInSeconds)
        let currentLap = completedHours + 1
        
        let nextBellSeconds = Double(currentLap) * hourInSeconds
        let nextBellDate = race.startDate.addingTimeInterval(nextBellSeconds)
        let remaining = nextBellDate.timeIntervalSince(now)
        
        return State(currentLap: currentLap, timeRemaining: remaining, nextBell: nextBellDate, status: .active)
    }
    
    
    static func formatTime(_ interval: TimeInterval) -> String {
        let ti = Int(interval)
        if ti < 0 { return "00:00" }
        let minutes = (ti % 3600) / 60
        let seconds = (ti % 3600) % 60
        
        return(String(format: "%02d:%02d", minutes, seconds))
        
    }
}
