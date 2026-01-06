//
//  RaceSetupMainView.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//

import SwiftUI

struct RaceSetupMainView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var viewModel = RaceCreationViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Form{
                    Section("Event Details"){
                        //Name
                        TextField("Event Name", text: $viewModel.name)
                        
                        //Type
                        Picker("Race Format", selection: $viewModel.selectedType){
                            ForEach(RaceType.allCases, id: \.self){type in
                                Text(type.displayName).tag(type)
                            }
                            .onChange(of: viewModel.selectedType) {
                                viewModel.initializeCheckpoints(for: viewModel.selectedType)
                            }
                        }
                        
                        //Date
                        DatePicker("Date", selection: $viewModel.startDate, displayedComponents: .date)
                        
                    }

                    Section("Safety Alerts") {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Warning Pace")
                                Spacer()
                                Text("\(Int(viewModel.warningPace)) min/km")
                                    .foregroundStyle(.orange)
                                    .fontWeight(.bold)
                            }
                            Stepper("Adjustment", value: $viewModel.warningPace, in: 5...60, step: 1)
                                .labelsHidden()
                            Text("Runners slower than this will be marked yellow.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Critical Pace")
                                Spacer()
                                Text("\(Int(viewModel.criticalPace)) min/km")
                                    .foregroundStyle(.red)
                                    .fontWeight(.bold)
                            }
                            Stepper("Adjustment", value: $viewModel.criticalPace, in: 10...120, step: 1)
                                .labelsHidden()
                            Text("Runners slower than this will be marked red.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Section("Course Setup"){
                        VStack{
                            //Link
                            NavigationLink{
                                CheckpointConfigView(viewModel: viewModel)
                                    .navigationTitle("Edit Course Map")
                            }label: {
                                HStack{
                                    Text("Configure Course")
                                    Spacer()
                                    Text("\(viewModel.checkpoints.count) Checkpoints")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            //Diagram
                            CourseMapDiagram(raceType: viewModel.selectedType, checkpoints: viewModel.checkpoints)
                        }
                    }
                    
                }
                .scrollContentBackground(.hidden)
                
                Button{
                    viewModel.save(context: context)
                    dismiss()
                }label: {
                    Text("Create Event")
                        .font(.system(size: 30,design: .rounded))
                        .foregroundStyle(Color(.white).opacity(0.8))
                        .frame(width: 300, height: 40)
                        .background(Color(!viewModel.name.isEmpty ? .slateBlue : .gray.opacity(0.3)))
                        .clipShape(.rect(cornerRadius: !viewModel.name.isEmpty ? 60 : 6))
                        .animation(.spring(duration:2.5), value: !viewModel.name.isEmpty)
                }
                .disabled(viewModel.name.isEmpty)
            }
            .navigationTitle("New Event")
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
            .onAppear{
                if viewModel.checkpoints.count < 2 {
                    viewModel.initializeCheckpoints(for: viewModel.selectedType)
                }
            }
            
            
        }
        
        
    }
}

#Preview {
    RaceSetupMainView()
}
