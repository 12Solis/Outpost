//
//  AppDependecies.swift
//  Outpost
//
//  Created by Leonardo Solís on 07/01/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class AppDependencies: ObservableObject {
    let container: ModelContainer
    let sessionManager: SessionManager
    let multipeerService: MultipeerService
    let syncManager: SyncManager
    
    init() {
        print(" Initializing App Dependencies...")
        
        let schema = Schema([Race.self, Checkpoint.self, Runner.self, StatusEvent.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create DB: \(error)")
        }
        
        self.sessionManager = SessionManager()
        self.multipeerService = MultipeerService()
        
        self.syncManager = SyncManager(service: self.multipeerService, context: self.container.mainContext)
        
        self.sessionManager.syncManager = self.syncManager
        
        self.multipeerService.start()
        
        print("Dependencies Ready. Session SyncManager is: \(self.sessionManager.syncManager == nil ? "NIL" : "LINKED")")
    }
}
