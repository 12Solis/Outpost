//
//  CSVExporter.swift
//  Outpost
//
//  Created by Leonardo Solís on 08/01/26.
//

import Foundation
import SwiftData

struct CSVExporter {
    static let headers = "Bib,Time,Checkpoint,Status,Segment Pace (min/km)"
    static let backyardHeaders = "Bib, Laps"
    
    
    static func generateCSV(for race: Race) -> URL? {
        var csvText = headers + "\n"
        
        let allRunners = race.runners.sorted { $0.bibNumber.localizedStandardCompare($1.bibNumber) == .orderedAscending }
        
        for runner in allRunners {
            let events = runner.history.sorted { $0.timestamp < $1.timestamp }
            
            for event in events {
                let bib = runner.bibNumber
                let time = event.timestamp.formatted(date: .omitted, time: .standard)
                let cpName = race.checkpoints.first(where: {$0.id == event.checkpointId})?.name ?? "Unknown CP"
                let status = event.type == .arrival ? "IN" : "OUT"
                let pace = "-"
                
                let row = "\(bib),\(time),\(cpName),\(status),\(pace)\n"
                csvText.append(row)
            }
        }
        
        let fileName = "\(race.name.replacingOccurrences(of: " ", with: "_"))_Results.csv"
        let tempDir = FileManager.default.temporaryDirectory 
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV Write Error: \(error)")
            return nil
        }
    }
    
    static func generateBackyardCSV(for race: Race) -> URL? {
        let viewModel = BackyardViewModel(race: race)
        
        var csvText = backyardHeaders + "\n"
        
        let allRunners = race.runners.sorted { $0.bibNumber.localizedStandardCompare($1.bibNumber) == .orderedAscending }
        
        for runner in allRunners {
            let bib = runner.bibNumber
            let laps = viewModel.countLaps(for: runner)
            let row = "\(bib),\(laps)\n"
            csvText.append(row)
        }
        
        let fileName = "\(race.name.replacingOccurrences(of: " ", with: "_"))_Results.csv"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do{
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV Write Error: \(error)")
            return nil
        }
    }
}     
