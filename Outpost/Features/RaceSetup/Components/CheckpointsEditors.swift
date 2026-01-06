//
//  CheckpointsEditors.swift
//  Outpost
//
//  Created by Leonardo Solís on 02/01/26.
//

import SwiftUI
import TipKit

struct  standardEditor: View {
    @Bindable var viewModel: RaceCreationViewModel
    var body: some View {
        Section {
            ForEach($viewModel.checkpoints) { $cp in
                HStack {
                    // Icon
                    Menu {
                        Picker("Type", selection: $cp.type) {
                            ForEach(CheckpointType.allCases) { type in
                                Label(type.displayName, systemImage: type.icon).tag(type)
                                    .selectionDisabled(type.displayName == "Finish Line" || type.displayName == "Start Line")
                            }
                        }
                        .onChange(of: cp.type) {
                            Task{await changeIconTip.iconChangedEvent.donate()}
                        }
                    } label: {
                        Image(systemName: cp.type.icon)
                            .foregroundStyle(Color(cp.type.color))
                            .frame(width: 24)
                    }
                    
                    // Fields
                    VStack(alignment: .leading) {
                        if cp.type == .start {
                            Text("Start Line")
                                .font(.headline)
                        } else if cp.type == .finish {
                            Text("Finish Line")
                                .font(.headline)
                        } else {
                            TextField("Name", text: $cp.name)
                                .font(.headline)
                        }
                        
                        if cp.type == .start {
                            Text("0 km").font(.caption).foregroundStyle(.secondary)
                        } else {
                            HStack(spacing: 2) {
                                TextField("0", value: $cp.distance, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                                Text("km").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        
                    }
                }
                .swipeActions {
                    if cp.type != .start && cp.type != .finish {
                        Button("Delete", role: .destructive) {
                            viewModel.removeCheckpoint(id: cp.id)
                        }
                    }
                }
                
            }
            .onMove(perform: viewModel.moveCheckpoint)
            
            Button("Add Checkpoint") {
                withAnimation { viewModel.addCheckpoint() }
            }
            
        } header: {
            Text("Linear Course")
        }
    }
}

struct backyardEditor: View {
    @Bindable var viewModel: RaceCreationViewModel
    
    var types: [CheckpointType] {
        CheckpointType.allCases.filter{ $0 != .finish}
    }
    var body: some View {
        Section {
            ForEach($viewModel.checkpoints) { $cp in
                HStack {
                    // Icon
                    Menu {
                        Picker("Type", selection: $cp.type) {
                            ForEach(types) { type in
                                Label(type.displayName, systemImage: type.icon).tag(type)
                                    .selectionDisabled(type.displayName == "Finish Line" || type.displayName == "Start Line")
                            }
                        }
                        .onChange(of: cp.type) {
                            Task{await changeIconTip.iconChangedEvent.donate()}
                        }
                        
                    } label: {
                        Image(systemName: cp.type.icon)
                            .foregroundStyle(Color(cp.type.color))
                            .frame(width: 24)
                    }
                    
                    // Fields
                    VStack(alignment: .leading) {
                        if cp.type == .start {
                            Text("Corral")
                                .font(.headline)
                        } else {
                            TextField("Name", text: $cp.name)
                                .font(.headline)
                        }
                        
                        if cp.type == .start {
                            Text("0 km").font(.caption).foregroundStyle(.secondary)
                        } else {
                            HStack(spacing: 2) {
                                TextField("0", value: $cp.distance, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50)
                                    .onSubmit {
                                        if cp.distance > 6.7 {cp.distance = 6.7}
                                    }
                                Text("km").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        
                    }
                }
                .swipeActions {
                    if cp.type != .start && cp.type != .finish {
                        Button("Delete", role: .destructive) {
                            viewModel.removeCheckpoint(id: cp.id)
                        }
                    }
                }
                
            }
            .onMove(perform: viewModel.moveCheckpoint)
            
            Button("Add Checkpoint") {
                withAnimation { viewModel.addCheckpoint() }
            }
        } footer: {
            Text("Backyard Ultra loops are fixed distance (6.7km). The main checkpoint is the Start/Finish corral.")
        }
    
    }
}

