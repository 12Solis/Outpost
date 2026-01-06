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
class SyncManager: ObservableObject {
    private let multipeerService: MultipeerService
    private let modelContext: ModelContext
    
    init(multipeerService: MultipeerService, modelContext: ModelContext) {
        self.multipeerService = multipeerService
        self.modelContext = modelContext
        
        
    }
    

    
}
