//
//  CheckpointConfigView.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//

import SwiftUI
import TipKit

struct CheckpointConfigView: View {
    @Bindable var viewModel: RaceCreationViewModel
    let iconTip = changeIconTip()
    
    var body: some View {
        VStack {
            CourseMapDiagram(raceType: viewModel.selectedType, checkpoints: viewModel.checkpoints)
                .padding(.horizontal)
            
            TipView(iconTip)
                .tipBackground(.slateBlue.opacity(0.2))
                .padding()
            
            List {
                if viewModel.selectedType == .backyard {
                    backyardEditor(viewModel: viewModel)
                } else {
                    standardEditor(viewModel: viewModel)
                }
            }
        }
        .toolbar {
            if viewModel.selectedType == .standard {
                EditButton()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    let backyard = RaceCreationViewModel()
    
    CheckpointConfigView(viewModel: backyard)
        .onAppear{backyard.selectedType = .backyard}
}
