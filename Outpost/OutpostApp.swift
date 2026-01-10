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
    
    @StateObject private var deps = AppDependencies()
    
    @AppStorage("HasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RaceSelectionView()
                    .environment(deps.sessionManager)
                    .environment(deps.multipeerService)
                    .environment(\.syncManager, deps.syncManager)
                    .task {
                        try? Tips.configure([
                            .datastoreLocation(.applicationDefault)
                        ])
                    }
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
        .modelContainer(deps.container)
    }
}
