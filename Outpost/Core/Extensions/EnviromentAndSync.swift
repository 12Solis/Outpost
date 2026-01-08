//
//  EnviromentAndSync.swift
//  Outpost
//
//  Created by Leonardo Solís on 06/01/26.
//

import Foundation

import SwiftUI

struct SyncManagerKey: EnvironmentKey {
    static let defaultValue: SyncManager? = nil
}

extension EnvironmentValues {
    var syncManager: SyncManager? {
        get { self[SyncManagerKey.self] }
        set { self[SyncManagerKey.self] = newValue }
    }
}
