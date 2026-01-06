//
//  OutpostApp.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct OutpostApp: App {
    @State private var sessionManager = SessionManager()
    @State private var multipeerService = MultipeerService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Race.self,
            Checkpoint.self,
            Runner.self,
            StatusEvent.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    
    var body: some Scene {
        WindowGroup {
            RaceSelectionView()
                .environment(sessionManager)
                .environment(multipeerService)
                .task {
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
