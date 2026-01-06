//
//  SessionManager.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class SessionManager{
    var activeRace: Race?
    var currentCheckpoint: Checkpoint?
    
    func selectRace(_ race: Race){
        self.activeRace = race
        self._currentCheckpoint = nil
    }
    
    func selectCheckpoint(_ checkpoint: Checkpoint){
        self.currentCheckpoint = checkpoint
    }
    
    func clearSession(){
        self.activeRace = nil
        self.currentCheckpoint = nil
    }
}
